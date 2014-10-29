//
//  YTMerchantAnnotation.h
//  HighGuang
//
//  Created by Yuan Tao on 10/17/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTAnnotation.h"
#import "RMMarker+RMMarker_YTExtension.h"
#import "YTMerchantLocation.h"
@interface YTMerchantAnnotation : YTAnnotation

-(id)initWithMapView:(RMMapView *)aMapView
 andMerchantLocation:(id<YTMerchantLocation>)merchantLocation;

@end
