//
//  YTLocalMall.h
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "YTStaticResourceManager.h"
#import "YTMall.h"
#import "YTLocalFloor.h"
@class YTCloudMall;
@interface YTLocalMall : NSObject<YTMall>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;
-(YTCloudMall *)getCloudMall;
@end
