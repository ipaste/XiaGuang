//
//  YTLocalFloor.h
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "YTDataManager.h"
#import "YTFloor.h"
#import "YTLocalMajorArea.h"
#import "YTLocalMall.h"
#import "YTLocalBlock.h"

@interface YTLocalFloor : NSObject<YTFloor>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;

@end
