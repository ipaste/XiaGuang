//
//  YTElevatorAnnotation.m
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//


#import "YTElevatorAnnotation.h"

@implementation YTElevatorAnnotation{
    id<YTElevator> _elevator;
    RMMarker *_resultLayer;
}

@synthesize displayLevel;

-(id)initWithMapView:(RMMapView *)aMapView
         andElevator:(id<YTElevator>)elevator
{
    self = [super initWithMapView:aMapView coordinate:[elevator coordinate] andTitle:nil];
    if(self){
        _elevator = elevator;
        
    }
    return self;
}


-(NSNumber *)displayLevel{
    return [_elevator displayLevel];
}

-(RMMapLayer *)produceLayer{
    if (!_resultLayer){
        _resultLayer = [[RMMarker alloc] initWithBubbleHeight:2 width:2];
    }
    return _resultLayer;
    
}

-(void)highlightAnimated:(BOOL)animated{
    [super highlightAnimated:animated];
    self.layer.opacity = 1;
    [(RMMarker *)self.layer cancelSuperHighlight];
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_11"]];
}


-(void)hideAnimated:(BOOL)animated{
    [super hideAnimated:animated];
    self.layer.opacity = 0;
}

-(void)superHighlight:(BOOL)animated{
    [super superHighlight:animated];
    self.layer.opacity = 1;
    RMMarker *curLayer = (RMMarker *)self.layer;
    [curLayer superHightlightMerchantLayer];
    [curLayer showMerchantAnimation:animated];
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_11"]];
}

-(id)getSourceModel{
    return _elevator;
}


@end
