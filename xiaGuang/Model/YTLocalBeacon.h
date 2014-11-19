//
//  YTLocalBeacon.h
//  HighGuang
//
//  Created by Yuan Tao on 9/1/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTBeacon.h"
#import "FMResultSet.h"
#import "YTStaticResourceManager.h"
#import "YTLocalMinorArea.h"

@interface YTLocalBeacon : NSObject<YTBeacon>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;

@end
