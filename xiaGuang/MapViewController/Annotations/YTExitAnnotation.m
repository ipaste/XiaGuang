//
//  YTExitAnnotation.m
//  HighGuang
//
//  Created by Yuan Tao on 10/29/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTExitAnnotation.h"


@implementation YTExitAnnotation{
    id<YTExit> _exit;
}

@synthesize displayLevel;


-(id)initWithMapView:(RMMapView *)aMapView
         andExit:(id<YTExit>)exit
{
    self = [super initWithMapView:aMapView coordinate:[exit coordinate] andTitle:nil];
    if(self){
        _exit = exit;
        
    }
    return self;
}


-(NSNumber *)displayLevel{
    return [_exit displayLevel];
}

-(RMMapLayer *)produceLayer{
    RMMarker *resultLayer = [[RMMarker alloc] initWithBubbleHeight:2 width:2];
    if(self.state == YTAnnotationStateHighlighted){
        resultLayer.opacity = 1;
        
        [resultLayer showBubble:YES];
        [resultLayer setMerchantIcon:[UIImage imageNamed:@"nav_ico_8"]];
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
        [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_8"]];
        return;
    }
    [super highlightAnimated:animated];
    [(RMMarker *)self.layer showBubble:animated];
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_8"]];
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
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_8"]];
}

-(id)getSourceModel{
    return _exit;
}


@end
