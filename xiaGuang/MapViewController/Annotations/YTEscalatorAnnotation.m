//
//  YTEscalatorAnnotation.m
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTEscalatorAnnotation.h"

@implementation YTEscalatorAnnotation{
    id<YTEscalator> _escalator;
    RMMarker *_resultLayer;
}

@synthesize displayLevel;

-(id)initWithMapView:(RMMapView *)aMapView
        andEscalator:(id<YTEscalator>)escalator
{
    self = [super initWithMapView:aMapView coordinate:[escalator coordinate] andTitle:nil];
    if(self){
        _escalator = escalator;
        
    }
    return self;
}


-(NSNumber *)displayLevel{
    return [_escalator displayLevel];
}

-(RMMapLayer *)produceLayer{
    
    _resultLayer = [[RMMarker alloc] initWithBubbleHeight:2 width:2];
    return _resultLayer;
    
}

-(void)highlightAnimated:(BOOL)animated{
    [super highlightAnimated:animated];
    self.layer.opacity = 1;
    [(RMMarker *)self.layer cancelSuperHighlight];
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_10"]];
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
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_10"]];
}

-(id)getSourceModel{
    return _escalator;
}

@end