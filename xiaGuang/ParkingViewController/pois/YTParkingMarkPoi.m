//
//  YTParkingMarkPoi.m
//  xiaGuang
//
//  Created by YunTop on 14/10/31.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTParkingMarkPoi.h"

@implementation YTParkingMarkPoi{
    CLLocationCoordinate2D _coord;
    NSString *_key;
}

-(instancetype)initWithParkingMarkCoordinat:(CLLocationCoordinate2D)coord{
    if (self = [super init]) {
        _coord = coord;
        _key = @"parkingMark";
    }
    return self;
}
-(NSString *)poiKey{
    return _key;
}

-(YTAnnotation *)produceAnnotationWithMapView:(RMMapView *)mapView{
    YTParkingMarkAnnotation *resultAnnotation = [[YTParkingMarkAnnotation alloc]initWithMapView:mapView coordinate:_coord andTitle:_key];
    return resultAnnotation;
}
@end
