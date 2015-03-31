//
//  YTPathAnnotation.h
//  虾逛
//
//  Created by Yuan Tao on 1/5/15.
//  Copyright (c) 2015 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTAnnotation.h"
#import "YTMapGraph.h"
#import "YTCanonicalCoordinate.h"
#import "YTMapGraphDict.h"
@interface YTPathAnnotation : YTAnnotation

-(id)initWithMapView:(RMMapView *)mapView
           majorArea:(id<YTMajorArea>)majorArea
          fromPoint1:(CGPoint)p1
            toPoint2:(CGPoint)p2;

-(instancetype) initWithMapView:(RMMapView *)mapView majorArea:(id<YTMajorArea>)majorArea;
-(void)changeStartPoint:(CGPoint)p;

@end
