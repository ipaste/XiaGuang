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
    
    RMMarker *resultLayer = [[RMMarker alloc] initWithBubbleHeight:2 width:2];
    if(self.state == YTAnnotationStateHighlighted){
        resultLayer.opacity = 1;
        
        [resultLayer showBubble:YES];
        [resultLayer setMerchantIcon:[UIImage imageNamed:@"nav_ico_11"]];
    }
    if(self.state == YTAnnotationStateHidden){
        
        resultLayer.opacity = 0;
    }
    
    return resultLayer;

}

-(void)highlightAnimated:(BOOL)animated{
    if(self.state == YTAnnotationStateSuperHighlighted){
        [super highlightAnimated:animated];
        [(RMMarker *)self.layer cancelSuperHighlight];
        [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_11"]];
        return;
    }
    [super highlightAnimated:animated];
    [(RMMarker *)self.layer showBubble:animated];
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_11"]];
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
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_11"]];
}

-(id)getSourceModel{
    return _elevator;
}


@end
