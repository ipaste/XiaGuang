//
//  YTMinorAreaAnnotation.h
//  虾逛
//
//  Created by Yuan Tao on 11/24/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTAnnotation.h"
#import "RMMarker+RMMarker_YTExtension.h"
#import "YTMinorArea.h"
@interface YTMinorAreaAnnotation : YTAnnotation

-(id)initWithMapView:(RMMapView *)aMapView
   andMinorArea:(id<YTMinorArea>)minorArea;

@end
