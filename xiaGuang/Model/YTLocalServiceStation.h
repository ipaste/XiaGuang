//
//  YTLocalServiceStation.h
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTServiceStation.h"
#import "YTLocalMajorArea.h"
#import "FMDatabase.h"
#import "YTDataManager.h"
#import "YTServiceStationPoi.h"

@interface YTLocalServiceStation : NSObject<YTEscalator>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;

@end
