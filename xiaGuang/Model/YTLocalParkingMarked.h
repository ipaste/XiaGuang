//
//  YTLocalParking.h
//  xiaGuang
//
//  Created by YunTop on 14/11/3.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTParkingMarked.h"
#import "YTUserDefaults.h"
#import "YTDataManager.h"
#import "YTParkingMarkPoi.h"
#import "YTLocalMajorArea.h"
#import "YTLocalMinorArea.h"
#define PARKING_CLASS_KEY @"parking"
#define PARKING_MINOR_KEY @"minorAreaID"
#define PARKING_MAJOR_KEY @"majorAreaID"
#define PARKING_NAME_KEY @"name"
#define PARKING_TIME_KEY @"time"
@interface YTLocalParkingMarked : NSObject<YTParkingMarked>
+(instancetype)standardParking;

@end
