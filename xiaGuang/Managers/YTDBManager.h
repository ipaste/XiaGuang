//
//  YTDBManager.h
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
@interface YTDBManager : NSObject

+(FMDatabase *)sharedManager;

@end
