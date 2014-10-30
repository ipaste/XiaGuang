//
//  YTCloudMinorArea.m
//  HighGuang
//
//  Created by Yuan Tao on 8/6/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTCloudMinorArea.h"

@implementation YTCloudMinorArea{
    AVObject *_internalObject;
    NSMutableArray *_beacons;
}

@synthesize beacons;
@synthesize coordinate;
@synthesize identifier;
@synthesize majorArea;
@synthesize minorAreaName;
-(id) initWithAVObject:(AVObject *)object{
    self = [super init];
    if(self){
        _internalObject = object;
    }
    return self;
}

-(NSString *)identifier{
    return _internalObject.objectId;
}

-(CLLocationCoordinate2D )coordinate{
    double x = [((NSNumber *)_internalObject[MINORAREA_CLASS_X_KEY]) doubleValue];
    double y = [((NSNumber *)_internalObject[MINORAREA_CLASS_Y_KEY]) doubleValue];
    return CLLocationCoordinate2DMake(x, y);
}


-(NSArray *)beacons{
    if(_beacons == nil){
        AVQuery *beaconQuery = [[AVQuery alloc] initWithClassName:BEACON_CLASS_NAME];
        beaconQuery.maxCacheAge = 24*3600;
        beaconQuery.cachePolicy = kAVCachePolicyCacheElseNetwork;
        [beaconQuery includeKey:BEACON_CLASS_MINORAREA_KEY];
        [beaconQuery whereKey:BEACON_CLASS_MINORAREA_KEY equalTo:_internalObject];
        NSArray * result = [beaconQuery findObjects];
        _beacons = [[NSMutableArray alloc] init];
        for(AVObject *tempBeacon in result){
            YTCloudBeacon *beacon = [[YTCloudBeacon alloc] initWithAVObject:tempBeacon];
            [_beacons addObject:beacon];
        }
    }
    return _beacons;

}

-(NSString *)minorAreaName{
    return [_internalObject objectForKey:MINORAREA_CLASS_MINORAREANAME_KEY];
}

-(id<YTMajorArea>)majorArea{
    
    AVObject *area = [_internalObject objectForKey:MINORAREA_CLASS_MAJORAREA_KEY];
    YTCloudMajorArea *result = [[YTCloudMajorArea alloc] initWithAVObject:area];
    return result;
    
}

-(void)getBeaconsWithCallBack:(void (^)(NSArray *result,NSError *error))callback{
    
    
    if(_beacons == nil){
        AVQuery *beaconQuery = [[AVQuery alloc] initWithClassName:BEACON_CLASS_NAME];
        beaconQuery.maxCacheAge = 24*3600;
        beaconQuery.cachePolicy = kAVCachePolicyCacheElseNetwork;
        [beaconQuery includeKey:BEACON_CLASS_MINORAREA_KEY];
        [beaconQuery whereKey:BEACON_CLASS_MINORAREA_KEY equalTo:_internalObject];
        
        [beaconQuery findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
            
            if(error != nil){
                callback(nil,error);
                return;
            }
            _beacons = [[NSMutableArray alloc] init];
            for(AVObject *tempBeacon in objects){
                YTCloudBeacon *beacon = [[YTCloudBeacon alloc] initWithAVObject:tempBeacon];
                [_beacons addObject:beacon];
            }
            
            callback(_beacons,nil);
            return;
            
        }];
        
    }
    
    callback(_beacons,nil);
}



@end
