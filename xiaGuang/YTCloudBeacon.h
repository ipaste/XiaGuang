//
//  YTCloudBeacon.h
//  HighGuang
//
//  Created by Yuan Tao on 8/6/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTBeacon.h"
#import <AVObject.h>
#import "YTCloudMinorArea.h"

#define BEACON_CLASS_NAME @"Beacon"
#define BEACON_CLASS_MINOR_KEY @"minor"
#define BEACON_CLASS_MAJOR_KEY @"major"
#define BEACON_CLASS_MINORAREA_KEY @"minorArea"

@interface YTCloudBeacon : NSObject<YTBeacon>

-(id)initWithAVObject:(AVObject *)object;

@end
