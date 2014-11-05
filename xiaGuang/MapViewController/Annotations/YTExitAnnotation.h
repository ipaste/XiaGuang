//
//  YTExitAnnotation.h
//  HighGuang
//
//  Created by Yuan Tao on 10/29/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMarker+RMMarker_YTExtension.h"
#import "YTExit.h"

@interface YTExitAnnotation : YTAnnotation

-(id)initWithMapView:(RMMapView *)aMapView
         andExit:(id<YTExit>)exit;
@end
