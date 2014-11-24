//
//  YTBathroomAnnotation.m
//  HighGuang
//
//  Created by Yuan Tao on 10/22/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTBathroomAnnotation.h"

@implementation YTBathroomAnnotation{
    id<YTBathroom> _bathroom;
    RMMarker *_resultLayer;
}

@synthesize displayLevel;


-(id)initWithMapView:(RMMapView *)aMapView
 andBathroom:(id<YTBathroom>)bathroom
{
    self = [super initWithMapView:aMapView coordinate:[bathroom coordinate] andTitle:nil];
    if(self){
        _bathroom = bathroom;
        
    }
    return self;
}


-(NSNumber *)displayLevel{
    return [_bathroom displayLevel];
}

-(RMMapLayer *)produceLayer{
    _resultLayer = [[RMMarker alloc] initWithBubbleHeight:2 width:2];

    return _resultLayer;
}

-(void)highlightAnimated:(BOOL)animated{
    
    [super highlightAnimated:animated];
    self.layer.opacity = 1;
    [(RMMarker *)self.layer showBubble:animated];
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_9"]];
    

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
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_9"]];
}

-(id)getSourceModel{
    return _bathroom;
}


@end
