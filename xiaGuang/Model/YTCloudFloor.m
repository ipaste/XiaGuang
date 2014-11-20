//
//  YTCloudFloor.m
//  HighGuang
//
//  Created by Yuan Tao on 8/13/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTCloudFloor.h"



@implementation YTCloudFloor{
    AVObject *_internalObject;
    NSMutableArray *_majorAreas;
}

@synthesize majorAreas;
@synthesize block;
@synthesize floorName;
@synthesize identifier;

-(id)initWithAVObject:(AVObject *)object{
    self = [super init];
    if(self){
        _internalObject = object;
        
    }
    return self;
}

-(id<YTBlock>)block{
    YTCloudBlock *tmpBlock = [[YTCloudBlock alloc]initWithAVObject:_internalObject[FLOOR_CLASS_BLOCK_KEY]];
    return tmpBlock;
}

-(NSString *)floorName{
    return _internalObject[FLOOR_CLASS_FLOORNAME_KEY];
}

-(NSString *)identifier{
    return _internalObject.objectId;
}

-(NSArray *)majorAreas{
    if(_majorAreas == nil){
        _majorAreas = [[NSMutableArray alloc] init];
        AVQuery *query = [[AVQuery alloc] initWithClassName:MAJORAREA_CLASS_NAME];
        [query includeKey:@"floor.mall"];
        query.maxCacheAge = 24 * 3600;
        query.cachePolicy = kAVCachePolicyCacheElseNetwork;
        [query whereKey:MAJORAREA_CLASS_FLOOR_KEY equalTo:_internalObject];
        NSArray *result = [query findObjects];
        
        for(AVObject *tempObject in result){
            
            YTCloudMajorArea *majorArea = [[YTCloudMajorArea alloc] initWithAVObject:tempObject];
            [_majorAreas addObject:majorArea];
            
        }
    }
    
    return _majorAreas;
}

@end
