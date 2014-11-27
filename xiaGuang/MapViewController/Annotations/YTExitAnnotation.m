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
    RMMarker *_resultLayer;
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
    _resultLayer = [[RMMarker alloc] initWithBubbleHeight:2 width:2];
    return _resultLayer;
}

-(void)highlightAnimated:(BOOL)animated{
    [super highlightAnimated:animated];
    self.layer.opacity = 1;
    [(RMMarker *)self.layer cancelSuperHighlight];
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_8"]];

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
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_8"]];
}

-(id)getSourceModel{
    return _exit;
}


@end
