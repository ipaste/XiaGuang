//
//  YTParkingMarkAnnotation.m
//  xiaGuang
//
//  Created by YunTop on 14/10/31.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTParkingMarkAnnotation.h"

@implementation YTParkingMarkAnnotation{
    RMMarker *_resultLayer;
}
-(id)initWithMapView:(RMMapView *)aMapView coordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle{
    self = [super initWithMapView:aMapView coordinate:aCoordinate andTitle:aTitle];
    if (self) {
        
    }
    return self;
}
-(RMMapLayer *)produceLayer{
    _resultLayer = [[RMMarker alloc]initWithParkingMarkLayer];
    
    return _resultLayer;
}
-(void)highlightAnimated:(BOOL)animated{
    [super highlightAnimated:animated];
    [_resultLayer showParkingMark];
}
-(void)hideAnimated:(BOOL)animated{
    [super hideAnimated:animated];
    [_resultLayer hideParkingMark];
}
-(void)superHighlight:(BOOL)animated{
    [super superHighlight:animated];
}
-(NSString *)annotationKey{
    return @"parking";
}
@end
