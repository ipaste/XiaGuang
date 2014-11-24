//
//  YTMinorAreaAnnotation.m
//  虾逛
//
//  Created by Yuan Tao on 11/24/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTMinorAreaAnnotation.h"
#import "YTLocalBeacon.h"
@implementation YTMinorAreaAnnotation{
    id<YTMinorArea> _minorArea;
}

@synthesize displayLevel;

-(id)initWithMapView:(RMMapView *)aMapView
   andMinorArea:(id<YTMinorArea>)minorArea
{
    self = [super initWithMapView:aMapView coordinate:[minorArea coordinate] andTitle:nil];
    if(self){
        _minorArea = minorArea;
        self.annotationType = @"minor";
        
    }
    return self;
}


-(NSNumber *)displayLevel{
    return nil;
}

-(RMMapLayer *)produceLayer{
    YTLocalBeacon *beacon = [_minorArea beacons][0];
    NSString *major = [beacon.major stringValue];
    NSString *minor = [beacon.minor stringValue];
    RMMarker *resultLayer = [[RMMarker alloc] initWithBeaconForMajorAreaID:major  minorID:minor];
    resultLayer.opacity = 1;/*
    if(self.state == YTAnnotationStateHighlighted){
        resultLayer.opacity = 1;
        
        [resultLayer showBubble:YES];
        [resultLayer setMerchantIcon:[UIImage imageNamed:@"nav_ico_13"]];
    }
    if(self.state == YTAnnotationStateHidden){
        
        resultLayer.opacity = 0;
    }*/
    
    return resultLayer;
    
}

-(void)highlightAnimated:(BOOL)animated{
    if(self.state == YTAnnotationStateSuperHighlighted){
        [super highlightAnimated:animated];
        [(RMMarker *)self.layer cancelSuperHighlight];
        [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_13"]];
        return;
    }
    [super highlightAnimated:animated];
    [(RMMarker *)self.layer showBubble:animated];
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_13"]];
    self.layer.opacity = 1;
    
}


-(void)hideAnimated:(BOOL)animated{
    [super hideAnimated:animated];
    self.layer.opacity = 0;
}

-(void)superHighlight:(BOOL)animated{
    [super superHighlight:animated];
    RMMarker *curLayer = (RMMarker *)self.layer;
    [curLayer superHightlightMerchantLayer];
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_13"]];
}

-(id)getSourceModel{
    return _minorArea;
}


@end
