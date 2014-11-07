//
//  YTLocalMajorArea.h
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTMajorArea.h"
#import "FMDatabase.h"
#import "YTDBManager.h"
#import "YTLocalMinorArea.h"
#import "YTLocalFloor.h"
#import "YTLocalElevator.h"
#import "YTLocalMerchantInstance.h"
#import "YTLocalBathroom.h"
#import "YTLocalExit.h"
#import "YTLocalEscalator.h"
#import "YTLocalServiceStation.h"

@interface YTLocalMajorArea : NSObject<YTMajorArea>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;

@end
