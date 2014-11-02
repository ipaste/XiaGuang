//
//  YTParkingAnnotation.m
//  xiaGuang
//
//  Created by YunTop on 14/10/31.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTParkingAnnotation.h"

@implementation YTParkingAnnotation{
    RMMarker *_resultLayer;
}
-(id)initWithMapView:(RMMapView *)aMapView coordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle{
    self = [super initWithMapView:aMapView coordinate:aCoordinate andTitle:aTitle];
    if (self) {
        
    }
    return self;
}
-(RMMapLayer *)produceLayer{
   _resultLayer = [[RMMarker alloc]initWithParkingLayer];

    return _resultLayer;
}
-(void)highlightAnimated:(BOOL)animated{
    [super highlightAnimated:animated];
    [_resultLayer didAppear];
}
-(void)hideAnimated:(BOOL)animated{
    [super hideAnimated:animated];
    [_resultLayer disappear];
}
-(void)superHighlight:(BOOL)animated{
    [super superHighlight:animated];
}
-(NSString *)annotationKey{
    return @"parking";
}
@end
