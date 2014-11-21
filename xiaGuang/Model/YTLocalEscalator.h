//
//  YTLocalEscalator.h
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "YTEscalator.h"
#import "YTLocalMajorArea.h"
#import "FMDatabase.h"
#import "YTStaticResourceManager.h"
#import "YTEscalatorPoi.h"

@interface YTLocalEscalator : NSObject<YTEscalator>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;

@end
