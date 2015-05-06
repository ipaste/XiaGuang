//
//  YTMapGraphDict.h
//  虾逛
//
//  Created by Yuan Tao on 3/6/15.
//  Copyright (c) 2015 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTMapGraph.h"

@interface YTMapGraphDict : NSObject

+(id)sharedInstance;
-(YTMapGraph *)getGraphFromMajorArea:(id<YTMajorArea> )majorArea usingMapview:(RMMapView *)mapView;

@end
