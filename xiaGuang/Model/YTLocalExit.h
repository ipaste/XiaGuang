//
//  YTLocalExit.h
//  HighGuang
//
//  Created by Yuan Tao on 10/29/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "YTExit.h"
#import "YTLocalMajorArea.h"
#import "FMDatabase.h"
#import "YTDataManager.h"
#import "YTExitPoi.h"

@interface YTLocalExit : NSObject<YTExit>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;

@end
