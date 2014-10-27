//
//  YTCloudMinorArea.h
//  HighGuang
//
//  Created by Yuan Tao on 8/6/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMinorArea.h"
#import <AVObject.h>
#import <AVQuery.h>
#import "YTCloudMajorArea.h"
#import "YTCloudBeacon.h"

#define MINORAREA_CLASS_NAME @"MinorArea"
#define MINORAREA_CLASS_X_KEY @"x"
#define MINORAREA_CLASS_Y_KEY @"y"
#define MINORAREA_CLASS_MINORAREANAME_KEY @"minorAreaName"
#define MINORAREA_CLASS_MAJORAREA_KEY @"majorArea"

@interface YTCloudMinorArea : NSObject<YTMinorArea>

-(id) initWithAVObject:(AVObject *)object;

@end
