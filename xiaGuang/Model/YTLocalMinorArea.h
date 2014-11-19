//
//  YTLocalMinorArea.h
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"
#import "YTStaticResourceManager.h"
#import "YTMinorArea.h"
#import "YTLocalBeacon.h"
#import "YTLocalMajorArea.h"
@interface YTLocalMinorArea : NSObject<YTMinorArea>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;

@end
