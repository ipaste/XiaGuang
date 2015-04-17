//
//  YTDataManager.h
//  虾逛
//
//  Created by Silence on 15/4/16.
//  Copyright (c) 2015年 Silence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>
#import "Reachability.h"
#import "FMDB.h"

typedef NS_ENUM(NSInteger, YTNetworkSatus) {
    YTNetworkSatusNotNomal = 0,
    YTNetworkSatusWifi,
    YTNetworkSatusWWAN
};

@class YTDataManager;

@protocol YTDataManagerDelegate <NSObject>

@optional
- (void)networkStatusChanged:(YTNetworkSatus)status;
@end

@interface YTDataManager : NSObject

@property (weak ,nonatomic)id<YTDataManagerDelegate> delegate;
@property (readonly ,nonatomic) FMDatabase *database;
@property (readonly ,nonatomic) FMDatabase *userDatebase;
@property (readonly ,nonatomic) NSString *documentMapPath;

+ (instancetype)defaultDataManager;
- (YTNetworkSatus)currentNetworkStatus;
- (void)closeAllDatebase;
@end
