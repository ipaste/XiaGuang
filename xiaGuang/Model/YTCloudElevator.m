//
//  YTCloudElevator.m
//  HighGuang
//
//  Created by Yuan Tao on 8/26/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTCloudElevator.h"

@implementation YTCloudElevator{
    AVObject *_internalObject;
}

@synthesize majorArea;
@synthesize inMinorArea;
@synthesize coordinate;
@synthesize identifier;

-(id)initWithAVObject:(AVObject *)object{
    self = [super init];
    if(self){
        _internalObject = object;
    }
    return self;
}

-(NSString *)identifier{
    return _internalObject.objectId;
}

-(id<YTMajorArea>)majorArea{
    return [[YTCloudMajorArea alloc] initWithAVObject:_internalObject[@"majorArea"]];
}

-(id<YTMinorArea>)inMinorArea{
    return [[YTCloudMinorArea alloc] initWithAVObject:_internalObject[@"inMinorArea"]];
}

-(CLLocationCoordinate2D )coordinate{
    double x = [((NSNumber *)_internalObject[@"x"]) doubleValue];
    double y = [((NSNumber *)_internalObject[@"y"]) doubleValue];
    return CLLocationCoordinate2DMake(x, y);
}


@end
