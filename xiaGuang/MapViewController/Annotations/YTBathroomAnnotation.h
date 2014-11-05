//
//  YTBathroomAnnotation.h
//  HighGuang
//
//  Created by Yuan Tao on 10/22/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMarker+RMMarker_YTExtension.h"
#import "YTBathroom.h"

@interface YTBathroomAnnotation : YTAnnotation

-(id)initWithMapView:(RMMapView *)aMapView
 andBathroom:(id<YTBathroom>)bathroom;

@end
