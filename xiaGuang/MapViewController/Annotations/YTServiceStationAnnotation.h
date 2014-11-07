//
//  YTServiceStationAnnotation.h
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTAnnotation.h"
#import "RMMarker+RMMarker_YTExtension.h"
#import "YTServiceStation.h"
@interface YTServiceStationAnnotation : YTAnnotation

-(id)initWithMapView:(RMMapView *)aMapView
        andServiceStation:(id<YTServiceStation>)ServiceStation;

@end
