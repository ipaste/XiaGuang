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
    NSDictionary *_lostDict;
    NSDictionary *_distanceDict;
    NSMutableArray *_actives;
    ESTBeacon *_shiftPotential;
    int _lostCount;
    //number of times we see another beacon is closer before we shift primary beacon
    int _shiftCount;
    
    NSMutableDictionary *_whitelist;
    
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
        
        _whitelist = [[NSMutableDictionary alloc] init];
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
        [db open];
        FMResultSet *beacons = [db executeQuery:@"select * from Beacon"];
        while([beacons next]){
            YTMajorMinorPair *tmpPair = [[YTMajorMinorPair alloc] init];
            int major = [beacons intForColumn:@"major"];
            int minor = [beacons intForColumn:@"minor"];
            tmpPair.major = [NSNumber numberWithInt:major];
            tmpPair.minor = [NSNumber numberWithInt:minor];
            [_whitelist setObject:tmpPair forKey:[NSString  stringWithFormat:@"%@-%@",tmpPair.major,tmpPair.minor]];
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
    NSLog(@"listeners:%lu",(unsigned long)_listeners.count);
    for (id<YTBeaconManagerUpdateListener> listener in _listeners) {
        
        [listener YTBeaconManager:self rangedBeacons:beacons];
    }
    
    [self.delegate rangedBeacons:beacons];

}

-(BOOL)isBeaconInRange:(ESTBeacon *)beacon{
    
    
    return [_actives containsObject:beacon];
}


-(NSNumber *)computedDistanceForBeacon:(ESTBeacon *)beacon{
    NSNumber *distance = [_distanceDict valueForKey:beacon.macAddress];
    return distance;
}

- (NSArray *)filterWhiteListedBeacon:(NSArray *)list {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for(ESTBeacon *beacon in list){
        
        if([_whitelist objectForKey:[NSString  stringWithFormat:@"%@-%@",beacon.major,beacon.minor]] != nil){
            [result addObject:beacon];
        }
        
    }
    
    return result;
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
