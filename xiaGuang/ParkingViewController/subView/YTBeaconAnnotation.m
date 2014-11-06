//
//  YTBeaconAnnotation.m
//  xiaGuang
//
//  Created by YunTop on 14/11/6.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTBeaconAnnotation.h"

@implementation YTBeaconAnnotation{
    RMMarker *_resultLayer;
}
-(id)initWithMapView:(RMMapView *)aMapView coordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle{
    self = [super initWithMapView:aMapView coordinate:aCoordinate andTitle:aTitle];
    if (self) {
        
    }
    return self;
}
-(RMMapLayer *)produceLayer{
    _resultLayer = [[RMMarker alloc]initWithBeaconForMajorAreaID:[[self.minorArea majorArea] identifier] minorID:[self.minorArea identifier]];
    
    return _resultLayer;
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
    return @"beacon";
}
@end
