//
//  YTDataManager.m
//  虾逛
//
//  Created by YunTop on 15/4/16.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTDataManager.h"
@interface YTDataManager(){
    Reachability *_reachability;
    NetworkStatus _currentNetworkStatus;
    FMDatabase *_tmpDatabase;
}

@end

@implementation YTDataManager

+ (instancetype)defaultDataManager{
    static YTDataManager *dataManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[YTDataManager alloc]init];
    });
    return dataManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        // Network Status
        _reachability = [Reachability reachabilityWithHostname:@"www.leancloud.cn"];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkStateChanged:) name:kReachabilityChangedNotification object:nil];
        [_reachability startNotifier];
        
        _tmpDatabase = [FMDatabase databaseWithPath:[[NSBundle mainBundle]pathForAuxiliaryExecutable:@"highGuangDB"]];
        
    }
    return self;
}

- (void)networkStateChanged:(NSNotification *)notification{
    switch (_reachability.currentReachabilityStatus) {
        case ReachableViaWiFi:
            NSLog(@"wifi");
            break;
            
        case ReachableViaWWAN:
            NSLog(@"wwan");
            break;
            
        case NotReachable:
            NSLog(@"no network");
            break;
    }
}

- (FMDatabase *)database {
    return _tmpDatabase;
}

@end
