//
//  YTBeconManager.m
//  Demo
//
//  Created by Yuan Tao on 7/31/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTBeaconManager.h"
#define SHIFT_THRESHOLD 1
#define LOST_THRESHOLD 1
#define DISTANCE_THRESHOLD 1

@interface YTMajorMinorPair : NSObject

@property (strong,nonatomic) NSNumber *major;
@property (strong,nonatomic) NSNumber *minor;

@end

@implementation YTMajorMinorPair


@end


@interface YTBeaconManager(){
    ESTBeaconManager *_estimoteBeaconManager;
    ESTBeaconRegion *_region;
    ESTBeacon *_currentClosest;
    NSDictionary *_lostDict;
    NSDictionary *_distanceDict;
    NSMutableArray *_actives;
    ESTBeacon *_shiftPotential;
    int _lostCount;
    //number of times we see another beacon is closer before we shift primary beacon
    int _shiftCount;
    
    NSMutableArray *_whitelist;
    
    NSHashTable *_listeners;
}

@end

@implementation YTBeaconManager
-(id)init{
    
    self = [super init];
    if(self){
        _estimoteBeaconManager = [[ESTBeaconManager alloc] init];
        _estimoteBeaconManager.delegate = self;
        
        
        _lostDict = [[NSDictionary alloc] init];
        _distanceDict = [[NSDictionary alloc] init];
        /*
        _region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                          identifier:@"EstimoteSampleRegion"];*/
        
        _whitelist = [[NSMutableArray alloc] init];
        FMDatabase *db = [YTDBManager sharedManager].db;
        [db open];
        FMResultSet *beacons = [db executeQuery:@"select * from Beacon"];
        while([beacons next]){
            YTMajorMinorPair *tmpPair = [[YTMajorMinorPair alloc] init];
            int major = [beacons intForColumn:@"major"];
            int minor = [beacons intForColumn:@"minor"];
            tmpPair.major = [NSNumber numberWithInt:major];
            tmpPair.minor = [NSNumber numberWithInt:minor];
            [_whitelist addObject: tmpPair];
        }
        
        _listeners = [NSHashTable weakObjectsHashTable];
    }
    
    return self;
}


+(id)sharedBeaconManager{
    static YTBeaconManager *beaconManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        beaconManager = [[self alloc]init];
    });
    return beaconManager;
}

-(void)startRangingBeacons{
    
    NSUUID *aprilBrotherId = [[NSUUID alloc] initWithUUIDString:@"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"];

    _region = [[ESTBeaconRegion alloc] initWithProximityUUID:aprilBrotherId identifier:@"us"];
    
    [_estimoteBeaconManager startRangingBeaconsInRegion:_region];
    _readbeacons = nil;
}


-(void)stopRanging{
    [_estimoteBeaconManager stopRangingBeaconsInRegion:_region];
}

-(void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region{
   
    
    beacons = [self filterWhiteListedBeacon:beacons];
    _readbeacons = beacons;
    
    
    
    // notify all listeners
    for (id<YTBeaconManagerUpdateListener> listener in _listeners) {
        [listener YTBeaconManager:self rangedBeacons:beacons];
    }
    
    if(_lostCount == LOST_THRESHOLD){
        _currentClosest = nil;
        _shiftPotential = nil;
        [self.delegate noBeaconsFound];
        _lostCount++;
        return;
    }
    
    if([beacons count] == 0){
        
        NSLog(@"lost");
        
        if(_lostCount <= LOST_THRESHOLD){
            _lostCount++;
        }
        return;
    }
    
    
    ESTBeacon * closestBeacon = beacons[0]; // assumption here is closest is at index 0 returned from lower-level sdk
    
    if([closestBeacon.distance floatValue] == -1.0){
        _lostCount ++;
        return;
    }
    
    if(_shiftPotential == NULL){
        if(![closestBeacon equalTo:_currentClosest]){
            _shiftPotential = closestBeacon;
        }
    }
    
    if(![closestBeacon equalTo:_currentClosest]){
        
        if([_shiftPotential equalTo:closestBeacon]){
            
            _shiftCount++;
        }
        else{
            _shiftCount = 0;
            _shiftPotential = closestBeacon;
        }
        
    }
    
    
    
    if(_shiftCount >= SHIFT_THRESHOLD){
        _currentClosest = closestBeacon;
        _shiftCount = 0;
        _lostCount = 0;
        [self.delegate primaryBeaconShiftedTo:closestBeacon];
    }
    
    [self processDistance: beacons];
}

-(BOOL)isBeaconInRange:(ESTBeacon *)beacon{
    
    
    return [_actives containsObject:beacon];
}


-(NSNumber *)computedDistanceForBeacon:(ESTBeacon *)beacon{
    NSNumber *distance = [_distanceDict valueForKey:beacon.macAddress];
    return distance;
}


-(void)processDistance:(NSArray *)beacons{
    //todo:test code here once we get 2 beacons
    for (ESTBeacon *beacon in beacons){
        
        float curDistance = [beacon.distance floatValue];
        
        if(curDistance == -1.0){
            
            if([_actives containsObject:beacon]){
                
                NSNumber *curLostCount = [_lostDict valueForKey:beacon.macAddress];
                if(curLostCount == NULL){
                    curLostCount = [NSNumber numberWithInteger: 0];
                }
            
                curLostCount = [NSNumber numberWithInteger: [curLostCount intValue]+1];
                if([curLostCount intValue] >= LOST_THRESHOLD){
                    [_actives removeObject:beacon];
                    [_lostDict setValue:NULL forKey:beacon.macAddress];
                }
            }
            
        }
        
        else{
            //compute distance here!!! need another beacon for this.
        }
    }
    
}

- (NSArray *)filterWhiteListedBeacon:(NSArray *)list {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(ESTBeacon *beacon in list){
        
        for(YTMajorMinorPair *pair in _whitelist){
            
            if([beacon.minor isEqual:pair.minor] && [beacon.major isEqual:pair.major]){
                [result addObject:beacon];
            }
        }
    }
    
    return result;
}

-(ESTBeacon *)currentClosest{
    return _currentClosest;
}

- (void)addListener:(id<YTBeaconManagerUpdateListener>)listener {
    [_listeners addObject:listener];
}

- (void)removeListener:(id<YTBeaconManagerUpdateListener>)listener {
    [_listeners removeObject:listener];
}

-(void)dealloc{
    NSLog(@"BeaconManager销毁");
    
}
@end
