//
//  YTExitPoi.h
//  HighGuang
//
//  Created by Yuan Tao on 10/29/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTPoi.h"
#import "YTExit.h"
#import "YTExitAnnotation.h"

@interface YTExitPoi : YTPoi

-(id)initWithExit:(id<YTExit>)exit;

@end
