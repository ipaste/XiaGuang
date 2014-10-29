//
//  YTAnnotation.m
//  HighGuang
//
//  Created by Yuan Tao on 10/16/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTAnnotation.h"

@implementation YTAnnotation

-(id)initWithMapView:(RMMapView *)aMapView coordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle{
    self = [super initWithMapView:aMapView coordinate:aCoordinate andTitle:aTitle];
    if(self){
        _state = YTAnnotationStateHidden;
        
    }
    return self;
}

-(void)highlightAnimated:(BOOL)animated{
    _state = YTAnnotationStateHighlighted;
}

-(void)superHighlight:(BOOL)animated{
    _state = YTAnnotationStateSuperHighlighted;
}


-(void)hideAnimated:(BOOL)animated{
    _state = YTAnnotationStateHidden;
}

@end
