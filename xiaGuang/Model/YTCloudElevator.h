//
//  YTCloudElevator.h
//  HighGuang
//
//  Created by Yuan Tao on 8/26/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTElevator.h"
#import <AVOSCloud/AVOSCloud.h>
#import "YTCloudMajorArea.h"
#import "YTCloudMinorArea.h"
#define ELEVATOR_CLASS_NAME @"Elevator"
#define ELEVATOR_MAJORAREA_KEY @"majorArea"
#define ELEVATOR_INMINORAREA_KEY @"inMinorArea"
@interface YTCloudElevator : NSObject<YTElevator>

-(id)initWithAVObject:(AVObject *)object;

@end
