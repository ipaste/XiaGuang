//
//  YTBeaconBasedLocator.m
//  xiaGuang
//
//  Created by Meng Hu on 11/5/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTBeaconBasedLocator.h"

#import "YTKalmanFilteredPositionBot.h"
#import "YTCanonicalCoordinate.h"
#import "YTDistanceData.h"
#import "YTPositionBot.h"
#import "YTDistanceBoundingBox.h"

#import "YTStaticResourceManager.h"

@interface YTBeaconBasedLocator() {
    RMMapView *_mapView;
    YTBeaconManager *_beaconManager;
    id<YTMajorArea> _majorArea;
    
    NSMutableDictionary *_distDict;
    
    YTKalmanFilteredPositionBot *_kalmanFilterBot;
    YTPositionBot *_positionBot;
    
    YTDistanceBoundingBox *_boundingBox;
}

- (NSArray *)prepareDistances:(NSArray *)beacons;

- (void)cleanDistDict;

@end

@implementation YTBeaconBasedLocator

- (id)initWithMapView:(RMMapView *)mapView
        beaconManager:(YTBeaconManager *)beaconManager
            majorArea:(id<YTMajorArea>)majorArea {
    self = [super init];
    if (self) {
        _mapView = mapView;
        
        _beaconManager = beaconManager;
        [_beaconManager addListener:self];
        
        _majorArea = majorArea;
        
        _distDict = [[NSMutableDictionary alloc] init];
        
        _kalmanFilterBot = [[YTKalmanFilteredPositionBot alloc] initWithTimeUpdateInterval:0.1
                                                                                   mapView:_mapView];
        
        _positionBot = [[YTPositionBot alloc] init];
        
        _boundingBox = [[YTDistanceBoundingBox alloc] initWithMapView:_mapView
                                                            majorArea:_majorArea];
    }
    return self;   
}

- (void)start {
    [_kalmanFilterBot start];
}

-(void)YTBeaconManager:(YTBeaconManager *)manager
         rangedBeacons:(NSArray *)beacons {
    
    NSArray *distances = [self prepareDistances:beacons];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSValue *pos = [_positionBot locateMeWithDistances:distances accuracy:0.00001];
        
        if (pos == nil) {
            return;
        }
        
        CGPoint position = [pos CGPointValue];
        
        position = [_kalmanFilterBot reportSample:position];
        
        position = [_boundingBox updateAndGetCurrentPoint:position];
        
        CLLocationCoordinate2D loc = [YTCanonicalCoordinate canonicalToMapCoordinate:position
                                                                             mapView:_mapView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate YTBeaconBasedLocator:self coordinateUpdated:loc];
        });
    });
}

- (NSArray *)prepareDistances:(NSArray *)beacons {
    
    NSMutableArray *distances = [[NSMutableArray alloc] init];
    
    for (ESTBeacon *beacon in beacons) {
        
        double dist = -1.0;
        
        if ([beacon.distance intValue] != -1) {
            dist =  [YTCanonicalCoordinate worldToCanonicalDistance:[beacon.distance doubleValue]
                                                            mapView:_mapView
                                                          majorArea:_majorArea];
        }
        
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
        
        int major = [beacon.major intValue];
        int minor = [beacon.minor intValue];
        
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select * from Beacon where major=%d and minor=%d", major, minor]];
        
        if ([result next]) {
            
            int minorArea = [result intForColumn:@"minorAreaId"];
            
            FMResultSet *r2 = [db executeQuery:[NSString stringWithFormat:@"select * from MinorArea where minorAreaId=%d", minorArea]];
            
            if ([r2 next]) {
                
                double lat = [r2 doubleForColumn:@"latitude"];
                double lon = [r2 doubleForColumn:@"longtitude"];
                
                CGPoint p = [YTCanonicalCoordinate mapToCanonicalCoordinate:CLLocationCoordinate2DMake(lat, lon)
                                                                    mapView:_mapView];
                
                if (dist != -1.0) {
                    YTDistanceData *distData = [[YTDistanceData alloc] initWithLocationX:p.x y:p.y distance:dist];
                    
                    NSString *key = [NSString stringWithFormat:@"%d-%d", major, minor];
                    
                    NSDictionary *oldDict = [_distDict objectForKey:key];
                    
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    dict[@"data"] = distData;
                    dict[@"count"] = [NSNumber numberWithInt:0];
                    dict[@"time"] = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceReferenceDate]];
                    
                    [_distDict setObject:dict
                                  forKey:key];
                    
                    
                    YTDistanceData *adjustedDist = distData;
                    
                    if (oldDict != nil) {
                        YTDistanceData *oldDist = oldDict[@"data"];
                        
                        double distDiff = distData.distance - oldDist.distance;
                        
                        double ratio = 2; // adjust this value
                        
                        double dist = MAX(0.01, oldDist.distance + ratio * distDiff);
                        
                        adjustedDist = [[YTDistanceData alloc] initWithLocationX:oldDist.x
                                                                               y:oldDist.y
                                                                        distance:dist];
                    }
                    
                    [distances addObject:adjustedDist];
                    
                } else {
                    NSMutableDictionary *dict = [_distDict objectForKey:[NSString stringWithFormat:@"%d-%d", major, minor]];
                    if (dict != nil) {
                        NSNumber *count = dict[@"count"];
                        
                        if ([count intValue] >= 3) {
                            [_distDict removeObjectForKey:[NSString stringWithFormat:@"%d-%d", major, minor]];
                        } else {
                            [distances addObject:dict[@"data"]];
                            
                            dict[@"count"] = [NSNumber numberWithInt:[count intValue] + 1];
                        }
                    }
                }
            }
        }
    }
    
    [self cleanDistDict];
    
    return distances;
}

- (void)cleanDistDict {
    double now = [[NSDate date] timeIntervalSinceReferenceDate];
    
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    
    for (NSString *key in [_distDict allKeys]) {
        NSDictionary *dict = _distDict[key];
        
        double time = [dict[@"time"] doubleValue];
        
        // allow 5 minutes of beacon cache
        if (now - time >= 300) {
            [keys addObject:key];
        }
    }
    
    for (NSString *key in keys) {
        [_distDict removeObjectForKey:key];
    }
}

-(void)dealloc{
    NSLog(@"locator destroyed");
}

@end
