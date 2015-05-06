//
//  YTAnnotation.h
//  HighGuang
//
//  Created by Yuan Tao on 10/16/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mapbox.h"

@interface YTAnnotation : RMAnnotation

typedef enum {
    YTAnnotationStateHighlighted = 0,
    YTAnnotationStateSuperHighlighted = 1,
    YTAnnotationStateHidden = 2
} YTAnnotationState;

@property (nonatomic,readonly) NSNumber * displayLevel;
@property (nonatomic,readonly) YTAnnotationState state;
@property (nonatomic,weak) NSString *annotationKey;




-(id)initWithMapView:(RMMapView *)aMapView coordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle;

-(void)highlightAnimated:(BOOL)animated;

-(void)superHighlight:(BOOL)animated;

-(void)hideAnimated:(BOOL)animated;


-(RMMapLayer *)produceLayer;
-(id)getSourceModel;

@end
