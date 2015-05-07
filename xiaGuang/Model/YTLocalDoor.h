//
//  YTLocalDoor.h
//  虾逛
//
//  Created by Yuan Tao on 12/15/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTDoor.h"
#import "FMDatabase.h"

@interface YTLocalDoor : NSObject<YTDoor>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;

@end
