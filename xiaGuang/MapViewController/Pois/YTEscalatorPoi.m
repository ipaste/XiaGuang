//
//  YTEscalatorPoi.m
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTEscalatorPoi.h"



@implementation YTEscalatorPoi{
    id<YTEscalator> _escalator;
    NSString *_key;
}

-(id)initWithEscalator:(id<YTEscalator>)escalator{
    self = [super init];
    if(self){
        _escalator = escalator;
    }
    return self;
}

@synthesize poiKey;

-(NSString *)poiKey{
    if(_key==nil){
        _key = [NSString stringWithFormat:@"escalator-%@",[_escalator identifier]];
        
    }
    return _key;
}

-(YTAnnotation *)produceAnnotationWithMapView:(RMMapView *)mapView{
    YTEscalatorAnnotation *resultAnnotation = [[YTEscalatorAnnotation alloc] initWithMapView:mapView andEscalator:_escalator];
    resultAnnotation.annotationKey = [self poiKey];
    
    return resultAnnotation;
}

-(id)sourceModel{
    return _escalator;
}


@end
