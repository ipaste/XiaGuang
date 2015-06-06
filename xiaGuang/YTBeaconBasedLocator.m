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
#import "YTDeadReckoning.h"
#import "YTMapGraph.h"
#import "YTDataManager.h"

@interface YTBeaconBasedLocator() <YTDeadReckoningDelegate> {
    RMMapView *_mapView;
    YTBeaconManager *_beaconManager;
    id<YTMajorArea> _majorArea;
    
    NSMutableDictionary *_distDict;
    
    YTKalmanFilteredPositionBot *_kalmanFilterBot;
    YTPositionBot *_positionBot;
    
    YTDistanceBoundingBox *_boundingBox;
    
    dispatch_queue_t _queue;
    
    YTDeadReckoning *_inertia;
    
    YTMapGraph *_mapGraph;
    
    BOOL _isRefresh;// switch for using deadreckoning
    
    __block NSDictionary *_projectionResult;
    
}

- (NSArray *)prepareDistances:(NSArray *)beacons;

- (void)cleanDistDict;

@end

@implementation YTBeaconBasedLocator

- (id)initWithMapView:(RMMapView *)mapView
        beaconManager:(YTBeaconManager *)beaconManager
            majorArea:(id<YTMajorArea>)majorArea
            mapOffset:(double)offset{
    self = [super init];
    if (self) {
        _mapView = mapView;
        
        _beaconManager = beaconManager;
        //[_beaconManager addListener:self];
        
        _majorArea = majorArea;
        
        _distDict = [[NSMutableDictionary alloc] init];
        
        _projectionResult = [[NSMutableDictionary alloc] init];
        
        _kalmanFilterBot = [[YTKalmanFilteredPositionBot alloc] initWithTimeUpdateInterval:0.1
                                                                                   mapView:_mapView];
        _positionBot = [[YTPositionBot alloc] init];
        
        _boundingBox = [[YTDistanceBoundingBox alloc] initWithMapView:_mapView
                                                            majorArea:_majorArea];
        
        _queue = dispatch_queue_create("bigbadboy",DISPATCH_QUEUE_CONCURRENT);
        
        _inertia = [[YTDeadReckoning alloc] initWithMapView:_mapView majorArea:_majorArea];
        _inertia.mapMeterPerPixel = 1;
        _inertia.mapNorthOffset = offset;
        _inertia.delegate = self;
        
        _mapGraph = [[YTMapGraph alloc]initWithMajorArea:_majorArea mapView:_mapView];

    }
    return self;
}

- (void)start {
    [_kalmanFilterBot start];
    [_inertia startSensorReading];
}

-(void)YTBeaconManager:(YTBeaconManager *)manager
         rangedObjects:(NSArray *)objects {
    
    NSArray *distances = [self prepareDistances:objects];

    dispatch_async(_queue, ^{
        
        
//        double start = [[NSDate date] timeIntervalSinceReferenceDate];
        NSValue *pos = [_positionBot locateMeWithDistances:distances accuracy:0.00001];
        
        if (pos == nil) {
            return;
        }
        
        CGPoint position = [pos CGPointValue];
        
        position = [_kalmanFilterBot reportSample:position];
        
        position = [_boundingBox updateAndGetCurrentPoint:position];
        
        _projectionResult = [_mapGraph projectToGraphFromPoint:position];
        
        NSValue *value = _projectionResult[@"projectedPoint"];
        
        //to estimate the direction of the path
        PESGraphNode *node1 = _projectionResult[@"node1"];
        PESGraphNode *node2 = _projectionResult[@"node2"];
        
        CGPoint point1, point2;
        point1.x = [node1.additionalData[@"x"] doubleValue];
        point1.y = [node1.additionalData[@"y"] doubleValue];
        
        point2.x = [node2.additionalData[@"x"] doubleValue];
        point2.y = [node2.additionalData[@"y"] doubleValue];
        
//        NSValue *value = [_mapGraph projectToGraphFromPoint:position][@"projectedPoint"];
        
        if (value != nil) {
            position =  [value CGPointValue];
        }
        
        NSLog(@"before DR: %f, %f", position.x, position.y);
        
        _inertia.startPoint = position;
        _inertia.pathDirection = atan2(point1.y-point2.y, point1.x-point2.x);
        
        //if _isRefresh is false, deadreckoning is on
        if (_isRefresh) {
            [self positionUpdating:position];
        }
    
    });
}

-(void)positionUpdating:(CGPoint )position {
    //_isRefresh = false;
    
//    NSLog(@"output location: %f, %f", position.x, position.y);
    
    NSValue *value = [_mapGraph projectToGraphFromPoint:position][@"projectedPoint"];
    
    if (value != nil) {
        position =  [value CGPointValue];
    }
    
    NSLog(@"after DR: %f, %f", position.x, position.y);

    if (fabs(position.x) != INFINITY && fabs(position.y) != INFINITY && position.x != 0 && position.y != 0) {
    
        CLLocationCoordinate2D coord = [YTCanonicalCoordinate canonicalToMapCoordinate:position mapView:_mapView];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate YTBeaconBasedLocator:self coordinateUpdated:coord];
        });
    }
}

- (NSArray *)prepareDistances:(NSArray *)beacons {
    
    NSMutableArray *distances = [[NSMutableArray alloc] init];
    
    for (NSDictionary *beaconDict in beacons) {
        
        double dist = -1.0;
        
        ESTBeacon *beacon = beaconDict[@"Beacon"];
        
        NSNumber *distance = beaconDict[@"distance"];
        if ([distance intValue] != -1) {
            dist =  [YTCanonicalCoordinate worldToCanonicalDistance:[distance doubleValue]
                                                            mapView:_mapView
                                                          majorArea:_majorArea];
        }
        
        FMDatabase *db = [YTDataManager defaultDataManager].database;
        
        int major = [beacon.major intValue];
        int minor = [beacon.minor intValue];
        
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select * from Beacon where major=%d and minor=%d", major, minor]];
        
        if ([result next]) {
            
            int minorArea = [result intForColumn:@"minorAreaId"];
            
            FMResultSet *r2 = [db executeQuery:[NSString stringWithFormat:@"select * from MinorArea where minorAreaId=%d", minorArea]];
            
            
            if ([r2 next]) {
                
                NSString *majorAreaId = [r2 stringForColumn:@"majorAreaId"];
                
                if(![majorAreaId isEqualToString:_majorArea.identifier]){
                    
                    continue;
                    
                }
                
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
                        
                        double ratio = 4; // adjust this value
                        
                        double dist = MAX(0.01, oldDist.distance + ratio * distDiff);
                        
                        adjustedDist = [[YTDistanceData alloc] initWithLocationX:oldDist.x
                                                                               y:oldDist.y
                                                                        distance:dist];
                    }
                    
                    //NSLog(@"特殊 major:%@ minor:%@ adjusted distance:%f",beacon.major,beacon.minor,adjustedDist.distance);
                    [distances addObject:adjustedDist];
                    
                } else {
                    NSMutableDictionary *dict = [_distDict objectForKey:[NSString stringWithFormat:@"%d-%d", major, minor]];
                    if (dict != nil) {
                        NSNumber *count = dict[@"count"];
                        
                        if ([count intValue] >= 6) {
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
    
    [_kalmanFilterBot stop];
    
    [_inertia stopSensorReading];
    
    //dispatch_suspend(_queue);
    
    //dispatch_cancel(_queue);
}

@end
