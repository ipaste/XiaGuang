//
//  YTElevatorAnnotation.h
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTAnnotation.h"
#import "RMMarker+RMMarker_YTExtension.h"
#import "YTElevator.h"
@interface YTElevatorAnnotation : YTAnnotation

-(id)initWithMapView:(RMMapView *)aMapView
 andElevator:(id<YTElevator>)elevator;

@end
