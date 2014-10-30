//
//  YTLocalBlock.h
//  HighGuang
//
//  Created by Yuan Tao on 10/10/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTBlock.h"
#import "FMResultSet.h"
#import "YTDBManager.h"
#import "YTLocalMall.h"

@interface YTLocalBlock : NSObject<YTBlock>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;

@end
