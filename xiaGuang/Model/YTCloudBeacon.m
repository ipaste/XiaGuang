//
//  YTCloudBeacon.m
//  HighGuang
//
//  Created by Yuan Tao on 8/6/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTCloudBeacon.h"

@implementation YTCloudBeacon{
    AVObject *_internalObject;
    id<YTMinorArea> _minorArea;
}

@synthesize minor;
@synthesize major;
@synthesize identifier;
@synthesize minorArea;

-(id)initWithAVObject:(AVObject *)object
{
    self = [super init];
    if(self){
        _internalObject = object;
    }
    return self;
}

-(NSNumber *)minor{
    return _internalObject[BEACON_CLASS_MINOR_KEY];
}

-(NSNumber *)major{
    return _internalObject[BEACON_CLASS_MAJOR_KEY];
}

-(id<YTMinorArea>)minorArea{
    
    if(_minorArea == Nil){
        _minorArea =  [[YTCloudMinorArea alloc]
                       initWithAVObject:_internalObject[BEACON_CLASS_MINORAREA_KEY]];
    }
    
    return _minorArea;
}

@end
