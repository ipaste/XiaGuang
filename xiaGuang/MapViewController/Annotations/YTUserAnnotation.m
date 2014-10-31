//
//  YTUserAnnotation.m
//  HighGuang
//
//  Created by Yuan Tao on 10/20/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTUserAnnotation.h"

@implementation YTUserAnnotation

@synthesize annotationKey;

-(id)initWithMapView:(RMMapView *)aMapView andCoordinate:(CLLocationCoordinate2D)acoordinate{
    self = [super initWithMapView:aMapView coordinate:acoordinate andTitle:nil];
    if(self){
        
    }
    return self;
}

-(NSNumber *)displayLevel{
    //always display
    return [NSNumber numberWithInt:0];
}

-(RMMapLayer *)produceLayer{
    RMMarker *resultLayer = [[RMMarker alloc] initWithUserLocation];
    
    return resultLayer;
}

-(void)highlightAnimated:(BOOL)animated{
    [super highlightAnimated:animated];
}

-(void)hideAnimated:(BOOL)animated{
    [super hideAnimated:animated];
}

-(void)deactiveAnimated:(BOOL)animated{
    [super superHighlight:animated];
    
}

-(NSString *)annotationKey{
    return @"user";
}

@end
