//
//  YTCloudBlock.m
//  HighGuang
//
//  Created by Yuan Tao on 10/9/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTCloudBlock.h"

@implementation YTCloudBlock{
    AVObject *_internalObject;
    NSMutableArray *_floors;
}

@synthesize mall;
@synthesize blockName;
@synthesize floors;


-(id)initWithAVObject:(AVObject *)object{
    
    self = [super init];
    if(self){
        _internalObject = object;
        
    }
    return self;
}


-(id<YTMall>)mall{
    return [[YTCloudMall alloc] initWithAVObject:_internalObject[BLOCK_CLASS_MALL_KEY]];
}

-(NSString *)blockName{
    return _internalObject[BLOCK_CLASS_BLOCKNAME_KEY];
}

-(NSArray *)floors{
    if(_floors == nil){
        AVQuery *query = [[AVQuery alloc] initWithClassName:FLOOR_CLASS_NAME];
        [query whereKey:FLOOR_CLASS_BLOCK_KEY equalTo:_internalObject];
        query.maxCacheAge = 24*3600;
        query.cachePolicy = kAVCachePolicyCacheElseNetwork;
          
        [query includeKey:@"block,merchant,majorArea.floor,inMinorArea"];
        NSArray *queryResult = [query findObjects];
        
        NSMutableArray *tempFloors = [[NSMutableArray alloc]init];
        for(AVObject *floor in queryResult){
            YTCloudFloor *temp = [[YTCloudFloor alloc] initWithAVObject:floor];
            [tempFloors addObject:temp];
        }
        
        _floors = [[NSMutableArray alloc] initWithArray:tempFloors];
    }
    return _floors;
}

@end
