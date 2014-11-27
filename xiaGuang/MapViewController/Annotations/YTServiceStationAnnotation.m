//
//  YTServiceStationAnnotation.m
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTServiceStationAnnotation.h"

@implementation YTServiceStationAnnotation{
    id<YTServiceStation> _serviceStation;
    RMMarker *_resultLayer;
}

@synthesize displayLevel;

-(id)initWithMapView:(RMMapView *)aMapView
   andServiceStation:(id<YTServiceStation>)ServiceStation
{
    self = [super initWithMapView:aMapView coordinate:[ServiceStation coordinate] andTitle:nil];
    if(self){
        _serviceStation = ServiceStation;
        
    }
    return self;
}


-(NSNumber *)displayLevel{
    return [_serviceStation displayLevel];
}

-(RMMapLayer *)produceLayer{
    _resultLayer = [[RMMarker alloc] initWithBubbleHeight:2 width:2];
    
    return _resultLayer;
}

-(void)highlightAnimated:(BOOL)animated{
    [super highlightAnimated:animated];
    self.layer.opacity = 1;
    [(RMMarker *)self.layer cancelSuperHighlight];
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_13"]];
}


-(void)hideAnimated:(BOOL)animated{
    [super hideAnimated:animated];
    self.layer.opacity = 0;
}

-(void)superHighlight:(BOOL)animated{
    [super superHighlight:animated];
    RMMarker *curLayer = (RMMarker *)self.layer;
    [curLayer superHightlightMerchantLayer];
    [curLayer showMerchantAnimation:animated];
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_13"]];
}

-(id)getSourceModel{
    return _serviceStation;
}

@end