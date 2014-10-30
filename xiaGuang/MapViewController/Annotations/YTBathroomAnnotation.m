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
    RMMarker *resultLayer = [[RMMarker alloc] initWithBubbleHeight:2 width:2];
    if(self.state == YTAnnotationStateHighlighted){
        resultLayer.opacity = 1;
        
        [resultLayer showBubble:YES];
        [resultLayer setMerchantIcon:[UIImage imageNamed:@"nav_ico_9"]];
    }
    if(self.state == YTAnnotationStateHidden){
        
        resultLayer.opacity = 0;
    }
    
    return resultLayer;
}

-(void)highlightAnimated:(BOOL)animated{
    
    [super highlightAnimated:animated];
    [(RMMarker *)self.layer showBubble:YES];
    [(RMMarker *)self.layer setMerchantIcon:[UIImage imageNamed:@"nav_ico_9"]];
    self.layer.opacity = 1;

}


-(void)hideAnimated:(BOOL)animated{
    [super hideAnimated:animated];
    self.layer.opacity = 0;
}

-(void)superHighlight:(BOOL)animated{
    [super superHighlight:animated];
}

-(id)getSourceModel{
    return _bathroom;
}


@end
