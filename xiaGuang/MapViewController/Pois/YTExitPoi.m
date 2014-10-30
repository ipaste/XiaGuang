//
//  YTExitPoi.m
//  HighGuang
//
//  Created by Yuan Tao on 10/29/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTExitPoi.h"

@implementation YTExitPoi{
    id<YTExit> _exit;
    NSString *_key;
}

-(id)initWithExit:(id<YTExit>)exit{
    self = [super init];
    if(self){
        _exit = exit;
        
    }
    return self;
}

@synthesize poiKey;

-(NSString *)poiKey{
    if(_key==nil){
        
        _key = [NSString stringWithFormat:@"exit-%@",[_exit identifier]];
        
    }
    return _key;
}

-(YTAnnotation *)produceAnnotationWithMapView:(RMMapView *)mapView{
    YTExitAnnotation *resultAnnotation = [[YTExitAnnotation alloc] initWithMapView:mapView andExit:_exit];
    resultAnnotation.annotationKey = [self poiKey];
    
    return resultAnnotation;
}

-(id)sourceModel{
    return _exit;
}

@end
