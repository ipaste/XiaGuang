//
//  YTMajorAreaInstance.h
//  虾逛
//
//  Created by Yuan Tao on 1/22/15.
//  Copyright (c) 2015 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTLocalMajorArea.h"
@interface YTMajorAreaDict : NSObject

+(id)sharedInstance;
-(id<YTMajorArea>)getMajorAreaFromId:(NSString *)identifier;

@end
