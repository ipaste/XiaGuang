//
//  YTMerchantAnnotation.m
//  HighGuang
//
//  Created by Yuan Tao on 10/17/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTMerchantAnnotation.h"

@implementation YTMerchantAnnotation{
    id<YTMerchantLocation> _merchantLocation;
}

@synthesize displayLevel;

-(id)initWithMapView:(RMMapView *)aMapView
 andMerchantLocation:(id<YTMerchantLocation>)merchantLocation
{
    self = [super initWithMapView:aMapView coordinate:[merchantLocation coordinate] andTitle:nil];
    if(self){
        _merchantLocation = merchantLocation;
        
    }
    return self;
}


-(NSNumber *)displayLevel{
    return [_merchantLocation displayLevel];
}

-(RMMapLayer *)produceLayer{
    
    //RMMarker *resultLayer = [[RMMarker alloc] initWithBubbleHeight:[_merchantLocation lableHeight] width:[_merchantLocation lableWidth]];
    
    RMMarker *resultLayer = [[RMMarker alloc] initWithBubbleHeight:1 width:1];
    
    if(self.state == YTAnnotationStateHighlighted){
        
        [_merchantLocation getCloudThumbNailWithCallBack:^(UIImage *result, NSError *error) {
            [resultLayer setMerchantIcon:result];
        }];
        [resultLayer showMerchantAnimation:NO];
    }
    if(self.state == YTAnnotationStateHidden){
        
    }
    if(self.state == YTAnnotationStateSuperHighlighted){
        [_merchantLocation getCloudThumbNailWithCallBack:^(UIImage *result, NSError *error) {
            [resultLayer setMerchantIcon:result];
        }];
        [resultLayer showMerchantAnimation:NO];
        [resultLayer superHightlightMerchantLayer];
    }
    
    return resultLayer;
}

-(void)highlightAnimated:(BOOL)animated{
    [super highlightAnimated:animated];
    RMMarker *curLayer = (RMMarker *)self.layer;
    [_merchantLocation getCloudThumbNailWithCallBack:^(UIImage *result, NSError *error) {
        [curLayer setMerchantIcon:result];
    }];
    [curLayer showMerchantAnimation:animated];
}


-(void)hideAnimated:(BOOL)animated{
    [super hideAnimated:animated];
    RMMarker *curLayer = (RMMarker *)self.layer;
    [curLayer hideMerchantAnimation:YES];
    [curLayer cancelSuperHighlight];
}


-(void)superHighlight:(BOOL)animated{
    [super superHighlight:animated];
    RMMarker *curLayer = (RMMarker *)self.layer;
    [curLayer superHightlightMerchantLayer];
    [_merchantLocation getCloudThumbNailWithCallBack:^(UIImage *result, NSError *error) {
        [curLayer setMerchantIcon:result];
    }];
}

-(id)getSourceModel{
    return _merchantLocation;
}


@end
