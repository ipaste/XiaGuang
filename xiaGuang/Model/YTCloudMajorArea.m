//
//  YTCloudMajorArea.m
//  HighGuang
//
//  Created by Yuan Tao on 8/7/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTCloudMajorArea.h"



@implementation YTCloudMajorArea{
    AVObject *_internalObject;
    NSArray *_minorAreas;
    NSArray *_merchantLocations;
    NSArray *_elevators;
}

@synthesize minorAreas;
@synthesize mapName;
@synthesize identifier;
@synthesize floor;
@synthesize merchantLocations;
@synthesize elevators;



-(id)initWithAVObject:(AVObject *)object{
    self = [super init];
    if(self){
        _internalObject = object;
    }
    return self;
}

-(NSArray *)minorAreas{
    if(_minorAreas == nil){
        AVQuery *query = [[AVQuery alloc] initWithClassName:MINORAREA_CLASS_NAME];
        [query whereKey:MINORAREA_CLASS_MAJORAREA_KEY equalTo:_internalObject];
        query.maxCacheAge = 24*3600;
        query.cachePolicy = kAVCachePolicyCacheElseNetwork;
        [query includeKey:@"majorArea.floor,majorArea.mall"];
        NSArray *queryResult = [query findObjects];
        
        NSMutableArray *tempMinors = [[NSMutableArray alloc]init];
        for(AVObject *minorArea in queryResult){
            YTCloudMinorArea *temp = [[YTCloudMinorArea alloc] initWithAVObject:minorArea];
            [tempMinors addObject:temp];
        }
        
        _minorAreas = [[NSArray alloc] initWithArray:tempMinors];
    }
    return _minorAreas;
}

-(NSString *)mapName{
    return _internalObject[MAJORAREA_CLASS_MAPNAME_KEY];
}

-(NSString *)identifier{
    return _internalObject.objectId;
}

-(id<YTFloor>)floor{
    return [[YTCloudFloor alloc] initWithAVObject:_internalObject[MAJORAREA_CLASS_FLOOR_KEY]];
}

-(double)worldToMapRatio {
    return [_internalObject[MAJORAREA_CLASS_WORLDTOMAPRATIO_KEY] doubleValue];
}

//-(NSArray *)merchantLocations{
//    if(_merchantLocations == nil){
//        AVQuery *query = [[AVQuery alloc] initWithClassName:MERCHANTLOCATION_CLASS_NAME];
//        [query whereKey:MERCHANTLOCATION_CLASS_MAJORAREA_KEY equalTo:_internalObject];
//        query.maxCacheAge = 24*3600;
//        query.cachePolicy = kAVCachePolicyCacheElseNetwork;
//        [query includeKey:@"mall,floor,merchant,majorArea.floor,inMinorArea"];
//        NSArray *queryResult = [query findObjects];
//        
//        NSMutableArray *tempMerchantLocs = [[NSMutableArray alloc]init];
//        for(AVObject *merchantLoc in queryResult){
//            YTCloudMerchantLocation *temp = [[YTCloudMerchantLocation alloc] initWithAVObject:merchantLoc];
//            [tempMerchantLocs addObject:temp];
//        }
//        
//        _merchantLocations = [[NSArray alloc] initWithArray:tempMerchantLocs];
//    }
//    return _merchantLocations;
//}

//-(NSArray *)elevators{
//    if(_elevators == nil){
//        AVQuery *query = [[AVQuery alloc] initWithClassName:ELEVATOR_CLASS_NAME];
//        [query whereKey:ELEVATOR_MAJORAREA_KEY equalTo:_internalObject];
//        query.maxCacheAge = 24*3600;
//        query.cachePolicy = kAVCachePolicyCacheElseNetwork;
//        [query includeKey:@"majorArea,inMinorArea"];
//        NSArray *queryResult = [query findObjects];
//        
//        NSMutableArray *tempElevators = [[NSMutableArray alloc]init];
//        for(AVObject *elevator in queryResult){
//            YTCloudElevator *temp = [[YTCloudElevator alloc] initWithAVObject:elevator];
//            [tempElevators addObject:temp];
//        }
//        
//        _elevators = [[NSArray alloc] initWithArray:tempElevators];
//    }
//    return _elevators;
//}

-(id)cloudObject{
    return _internalObject;
}


@end
