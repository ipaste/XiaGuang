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
#define BUFFER_TIME 10
#define ALPHA 0.6
#define MAX_DISTANCE 40
@interface YTMajorMinorPair : NSObject

@property (strong,nonatomic) NSNumber *major;
@property (strong,nonatomic) NSNumber *minor;

@end

@implementation YTMajorMinorPair


@end


@interface YTBeaconManager(){
    ESTBeaconManager *_estimoteBeaconManager;
    ESTBeaconRegion *_aprilRegion;
    ESTBeaconRegion *_mircoChatRegion;
    NSDictionary *_lostDict;
    NSDictionary *_distanceDict;
    NSMutableArray *_actives;
    ESTBeacon *_shiftPotential;
    int _lostCount;
    //number of times we see another beacon is closer before we shift primary beacon
    int _shiftCount;
    
    NSMutableDictionary *_whitelist;
    
    NSHashTable *_listeners;
    NSMutableArray *_bufferBeacon;
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
        
        _whitelist = [[NSMutableDictionary alloc] init];
        FMDatabase *db = [YTDataManager defaultDataManager].database;
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
//        YTMajorMinorPair *tmpPaid = [[YTMajorMinorPair alloc]init];
//        tmpPaid.major = @1004;
//        tmpPaid.minor = @5025;
//        [_whitelist setObject:tmpPaid forKey:[NSString stringWithFormat:@"%@-%@",tmpPaid.major,tmpPaid.minor]];
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
    
    NSUUID *mircoChatId = [[NSUUID alloc] initWithUUIDString:@"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"];
    
    _aprilRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:aprilBrotherId identifier:@"us"];
    _mircoChatRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:mircoChatId identifier:@"WX"];
    
    [_estimoteBeaconManager startRangingBeaconsInRegion:_aprilRegion];
    [_estimoteBeaconManager startRangingBeaconsInRegion:_mircoChatRegion];
    _readbeacons = nil;
}


-(void)stopRanging{
    [_estimoteBeaconManager stopRangingBeaconsInRegion:_aprilRegion];
    [_estimoteBeaconManager startRangingBeaconsInRegion:_mircoChatRegion];
}

-(void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region{
    beacons = [self filterWhiteListedBeacon:beacons];
    _readbeacons = beacons;
    if (_bufferBeacon == nil) {
        _bufferBeacon = [NSMutableArray array];
        [beacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSNumber *distance = ((ESTBeacon *)obj).distance;
            if (![distance isEqualToNumber:@-1] && [distance doubleValue] < MAX_DISTANCE) {
                NSDictionary *beaconDict = @{@"Beacon":obj,@"time":[NSDate date],@"distance":distance};
                [_bufferBeacon addObject:beaconDict];
            }
            
            if (idx == beacons.count - 1) {
                // notify all listeners
                for (id<YTBeaconManagerUpdateListener> listener in _listeners) {
                    [listener YTBeaconManager:self rangedObjects:_bufferBeacon];
                }
                [self.delegate rangedObjects:_bufferBeacon];
                
            }
        }];
    }else{
        [beacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.Beacon.minor == %@ AND self.Beacon.major == %@",((ESTBeacon *)obj).minor,((ESTBeacon *)obj).major];
            NSArray *beaconSoure = [_bufferBeacon filteredArrayUsingPredicate:predicate];
            if (beaconSoure.count > 0){
                NSDictionary *dict = beaconSoure[0];
                NSInteger index = [_bufferBeacon indexOfObject:dict];
                ESTBeacon *newBeacon = obj;
                double d = -1;
                if (![newBeacon.distance isEqualToNumber:[NSNumber numberWithInt:-1]] && [newBeacon.distance doubleValue] < MAX_DISTANCE){
                    d = ALPHA * [newBeacon.distance doubleValue] + (1 - ALPHA) * [dict[@"distance"] doubleValue];
                    NSDictionary *beaconDict = @{@"Beacon":newBeacon,@"time":[NSDate date],@"distance":[NSNumber numberWithDouble:d]};
                    [_bufferBeacon replaceObjectAtIndex:index withObject:beaconDict];
                }
            }else{
                NSNumber *distance = ((ESTBeacon *)obj).distance;
                if (![distance isEqualToNumber:@-1] && [distance doubleValue] < MAX_DISTANCE){
                    NSDictionary *dict = @{@"Beacon":obj,@"time":[NSDate date],@"distance":((ESTBeacon *)obj).distance};
                    [_bufferBeacon addObject:dict];
                }
            }
            if (idx == beacons.count - 1) {
                [_bufferBeacon enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    //NSDictionary *dict = obj;
                    //ESTBeacon *beacon = obj[@"Beacon"];
                    NSTimeInterval time = [[NSDate date] timeIntervalSinceNow] - [((NSDate *)obj[@"time"] ) timeIntervalSinceNow];
                    if (time > BUFFER_TIME) {
                        [_bufferBeacon removeObject:obj];
                    }
                     //NSLog(@"%d. major:%@,minor:%@,old:%@,distance:%@",idx,beacon.major,beacon.minor,beacon.distance,dict[@"distance"]);
                    
                    if (idx == _bufferBeacon.count -1) {
                       // NSLog(@"==========     我是分割线 ==========");
                        // notify all listeners
                        for (id<YTBeaconManagerUpdateListener> listener in _listeners) {
                            [listener YTBeaconManager:self rangedObjects:_bufferBeacon];
                        }
                        [self.delegate rangedObjects:_bufferBeacon];
                        
                    }
                }];
            }
            
            
        }];
    }
    
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
