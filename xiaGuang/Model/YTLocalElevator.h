//
//  YTLocalElevator.h
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTElevator.h"
#import "YTLocalMajorArea.h"
#import "FMDatabase.h"
#import "YTStaticResourceManager.h"
#import "YTElevatorPoi.h"

@interface YTLocalElevator : NSObject<YTElevator>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;

@end
