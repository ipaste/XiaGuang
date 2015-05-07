//
//  YTElevatorPoi.m
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTElevatorPoi.h"

@implementation YTElevatorPoi{
    id<YTElevator> _elevator;
    NSString *_key;
}

-(id)initWithElevator:(id<YTElevator>)elevator{
    self = [super init];
    if(self){
        _elevator = elevator;
    }
    return self;
}

@synthesize poiKey;

-(NSString *)poiKey{
    if(_key==nil){
        _key = [NSString stringWithFormat:@"elevator-%@",[_elevator identifier]];
        
    }
    return _key;
}

-(YTAnnotation *)produceAnnotationWithMapView:(RMMapView *)mapView{
    YTElevatorAnnotation *resultAnnotation = [[YTElevatorAnnotation alloc] initWithMapView:mapView andElevator:_elevator];
    resultAnnotation.annotationKey = [self poiKey];
    
    return resultAnnotation;
}

-(id)sourceModel{
    return _elevator;
}


@end
