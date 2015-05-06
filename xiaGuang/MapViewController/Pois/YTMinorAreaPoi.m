//
//  YTMinorAreaPoi.m
//  虾逛
//
//  Created by Yuan Tao on 11/24/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTMinorAreaPoi.h"
@implementation YTMinorAreaPoi{
    id<YTMinorArea> _minorArea;
    NSString *_key;
}

-(id)initWithMinorArea:(id<YTMinorArea>)minorArea{
    self = [super init];
    if(self){
        _minorArea = minorArea;
    }
    return self;
}

@synthesize poiKey;

-(NSString *)poiKey{
    if(_key==nil){
        _key = [NSString stringWithFormat:@"minorArea-%@",[_minorArea identifier]];
    }
    return _key;
}

-(YTAnnotation *)produceAnnotationWithMapView:(RMMapView *)mapView{
    YTMinorAreaAnnotation *resultAnnotation = [[YTMinorAreaAnnotation alloc] initWithMapView:mapView andMinorArea:_minorArea];
    resultAnnotation.annotationKey = [self poiKey];
    
    return resultAnnotation;
}

-(id)sourceModel{
    return _minorArea;
}

@end
