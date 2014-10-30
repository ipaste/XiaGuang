//
//  YTCloudMajorArea.h
//  HighGuang
//
//  Created by Yuan Tao on 8/7/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMajorArea.h"
#import "YTCloudMinorArea.h"
#import <AVQuery.h>
#import <AVObject.h>
#import "YTCloudFloor.h"
//#import "YTCloudMerchantLocation.h"
//#import "YTCloudElevator.h"

#define MAJORAREA_CLASS_NAME @"MajorArea"
#define MAJORAREA_CLASS_MINORAREAS_KEY @"minorAreas"
#define MAJORAREA_CLASS_MAPNAME_KEY @"mapName"
#define MAJORAREA_CLASS_FLOOR_KEY @"floor"

@interface YTCloudMajorArea : NSObject<YTMajorArea>

-(id)initWithAVObject:(AVObject *)object;

@end
