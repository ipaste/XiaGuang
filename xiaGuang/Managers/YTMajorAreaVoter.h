//
//  YTMajorAreaVoter.h
//  虾逛
//
//  Created by Yuan Tao on 11/19/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ESTBeacon.h>
#import "YTMajorArea.h"
#import "YTStaticResourceManager.h"
#import "YTLocalMajorArea.h"

@interface YTMajorAreaVoter : NSObject

+(NSString *)shouldSwitchToMajorAreaId:(NSArray *)beacons;
+(id<YTMajorArea>)getMajorArea:(ESTBeacon *)beacon;

@end
