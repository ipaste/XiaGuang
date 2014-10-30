//
//  YTCloudFloor.h
//  HighGuang
//
//  Created by Yuan Tao on 8/13/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTFloor.h"
#import <AVOSCloud.h>
#import "YTCloudMajorArea.h"
#import "YTCloudMall.h"

#define FLOOR_CLASS_NAME @"Floor"
#define FLOOR_CLASS_FLOORNAME_KEY @"floorName"
#define FLOOR_CLASS_BLOCK_KEY @"block"

@interface YTCloudFloor : NSObject<YTFloor>

-(id) initWithAVObject:(AVObject *)object;

@end
