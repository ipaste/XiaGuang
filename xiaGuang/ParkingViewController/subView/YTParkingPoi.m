//
//  YTParkingPoi.m
//  xiaGuang
//
//  Created by YunTop on 14/10/31.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTParkingPoi.h"

@implementation YTParkingPoi{
    CLLocationCoordinate2D _coord;
    NSString *_key;
}
-(instancetype)initWithParkingCoordinat:(CLLocationCoordinate2D)coord{
    self = [super init];
    if (self) {
        _coord = coord;
        _key = @"parking";
    }
    return self;
}
-(NSString *)poiKey{
    return _key;
}
-(YTAnnotation *)produceAnnotationWithMapView:(RMMapView *)mapView{
    YTParkingAnnotation *resultAnnotation = [[YTParkingAnnotation alloc]initWithMapView:mapView coordinate:_coord andTitle:_key];
    return resultAnnotation;
}
@end
