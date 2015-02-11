//
//  YTStaticResourceManager.h
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "YTStaticResourceDownloader.h"

@interface YTStaticResourceManager : NSObject

@property (nonatomic, readonly) FMDatabase *db;

+(YTStaticResourceManager *)sharedManager;

- (void)startBackgroundDownload;
- (void)stopBackgroundDownload;

- (void)checkAndSwitchToNewStaticData;

- (void)restartCopyTheFile;

@end
