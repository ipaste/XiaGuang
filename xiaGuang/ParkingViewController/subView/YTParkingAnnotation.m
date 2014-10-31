//
//  YTParkingAnnotation.m
//  xiaGuang
//
//  Created by YunTop on 14/10/31.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTParkingAnnotation.h"

@implementation YTParkingAnnotation
-(id)initWithMapView:(RMMapView *)aMapView coordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle{
    self = [super initWithMapView:aMapView coordinate:aCoordinate andTitle:aTitle];
    if (self) {
        
    }
    return self;
}
-(RMMapLayer *)produceLayer{
    RMMarker *resultLayer = [[RMMarker alloc]initWithParkingLayer];
    return resultLayer;
}
-(void)highlightAnimated:(BOOL)animated{
    [super highlightAnimated:animated];
}
-(void)hideAnimated:(BOOL)animated{
    [super hideAnimated:animated];
}
-(void)superHighlight:(BOOL)animated{
    [super superHighlight:animated];
}
-(NSString *)annotationKey{
    return @"parking";
}
@end
