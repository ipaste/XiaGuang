//
//  YTParkingAnnotation.h
//  xiaGuang
//
//  Created by YunTop on 14/10/31.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTAnnotation.h"
#import "RMMarker+RMMarker_YTExtension.h"
@interface YTParkingCurrentAnnotation : YTAnnotation
-(id)initWithMapView:(RMMapView *)aMapView coordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle;
@end
