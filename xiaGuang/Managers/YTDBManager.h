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

@property (nonatomic, readonly) FMDatabase *db;

+(YTDBManager *)sharedManager;

- (void)startBackgroundDownload;
- (void)stopBackgroundDownload;

- (void)checkAndSwitchToNewDB;

@end
