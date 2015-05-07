//
//  YTBeaconPosistionPoi.m
//  xiaGuang
//
//  Created by YunTop on 14/11/6.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTBeaconPosistionPoi.h"

@implementation YTBeaconPosistionPoi{
    CLLocationCoordinate2D _coord;
    NSString *_key;
    YTBeaconAnnotation *_resultAnnotation;
    id<YTMinorArea> _tmpMinorArea;
}
-(instancetype)initWithParkingMarkCoordinat:(CLLocationCoordinate2D)coord minor:(id<YTMinorArea>)minorArea{
    self = [super init];
    if (self) {
        _coord = coord;
        _key = @"Beacon";
        _tmpMinorArea = minorArea;
    }
    return self;
}
-(NSString *)poiKey{
    return _key;
}
-(YTAnnotation *)produceAnnotationWithMapView:(RMMapView *)mapView{
    _resultAnnotation = [[YTBeaconAnnotation alloc]initWithMapView:mapView coordinate:_coord andTitle:_key];
    _resultAnnotation.minorArea = _tmpMinorArea;
    return _resultAnnotation;
}
@end
