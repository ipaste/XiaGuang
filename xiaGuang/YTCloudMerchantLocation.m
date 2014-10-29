//
//  YTCloudMerchantLocation.m
//  HighGuang
//
//  Created by Yuan Tao on 8/14/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTCloudMerchantLocation.h"
#import "YTCloudMall.h"
#import "YTMerchantPoi.h"

@implementation YTCloudMerchantLocation{
    AVObject *_internalObject;
}

@synthesize mall;
@synthesize majorArea;
@synthesize identifier;
@synthesize merchantLocationName;
@synthesize floor;
@synthesize coordinate;
@synthesize displayLevel;
@synthesize inMinorArea;

-(id)initWithAVObject:(AVObject *)object{
    self = [super init];
    if(self){
        _internalObject = object;
        
    }
    return self;
}

-(NSString *)merchantLocationName{
    return _internalObject[MERCHANTLOCATION_CLASS_NAME_KEY];
}

-(NSString *)address{
    return _internalObject[MERCHANTLOCATION_CLASS_ADDRESS_KEY];
}

-(CLLocationCoordinate2D )coordinate{
    double x = [((NSNumber *)_internalObject[MERCHANTLOCATION_CLASS_X_KEY]) doubleValue];
    double y = [((NSNumber *)_internalObject[MERCHANTLOCATION_CLASS_Y_KEY]) doubleValue];
    return CLLocationCoordinate2DMake(x, y);
}

-(NSNumber *)displayLevel{
    return _internalObject[MERCHANTLOCATION_CLASS_DISPLAYLEVEL_KEY];
}

-(id<YTMall>)mall{
    return [[YTCloudMall alloc]initWithAVObject:_internalObject[MERCHANTLOCATION_CLASS_MALL_KEY]];
}

-(id<YTFloor>)floor{
    
    return [[YTCloudFloor alloc]initWithAVObject:_internalObject[MERCHANTLOCATION_CLASS_FLOOR_KEY]];
}

-(id<YTMajorArea>)majorArea{
    
    return [[YTCloudMajorArea alloc]initWithAVObject:_internalObject[MERCHANTLOCATION_CLASS_MAJORAREA_KEY] ];
}

-(id<YTMinorArea>)inMinorArea{
    return [[YTCloudMinorArea alloc] initWithAVObject:_internalObject[MERCHANTLOCATION_CLASS_INMINORAREA_KEY]];
}


@end
