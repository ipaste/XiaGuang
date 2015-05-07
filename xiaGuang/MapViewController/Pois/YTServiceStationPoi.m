//
//  YTServiceStationPoi.m
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//


#import "YTServiceStationPoi.h"



@implementation YTServiceStationPoi{
    id<YTServiceStation> _serviceStation;
    NSString *_key;
}

-(id)initWithServiceStation:(id<YTServiceStation>)ServiceStation{
    self = [super init];
    if(self){
        _serviceStation = ServiceStation;
    }
    return self;
}

@synthesize poiKey;

-(NSString *)poiKey{
    if(_key==nil){
        _key = [NSString stringWithFormat:@"serviceStation-%@",[_serviceStation identifier]];
    }
    return _key;
}

-(YTAnnotation *)produceAnnotationWithMapView:(RMMapView *)mapView{
    YTServiceStationAnnotation *resultAnnotation = [[YTServiceStationAnnotation alloc] initWithMapView:mapView andServiceStation:_serviceStation];
    resultAnnotation.annotationKey = [self poiKey];
    
    return resultAnnotation;
}

-(id)sourceModel{
    return _serviceStation;
}


@end