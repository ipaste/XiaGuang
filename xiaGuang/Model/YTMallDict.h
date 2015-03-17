//
//  YTMallDict.h
//  虾逛
//
//  Created by YunTop on 15/3/13.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTCloudMall.h"
#import "YTLocalMall.h"

typedef NS_ENUM(NSInteger, YTMallClass) {
    YTMallClassCloud,
    YTMallClassLocal
};

@interface YTMallDict : NSObject

@property (readonly ,nonatomic) BOOL loadFinishes;
@property (readonly ,nonatomic) NSNumber *localMallMaxId;

+ (instancetype)sharedInstance;

// 获取网络所有的商城以及所有的本地商城
- (void)getAllCloudMallWithCallBack:(void (^)(NSArray *malls))callBack;
- (void)getAllLocalMallWithCallBack:(void (^)(NSArray *malls))callBack;

// 将任意类型的mall转换成云商城对象以及本地商城对象
- (id<YTMall>)changeMallObject:(id<YTMall>)mall resultType:(YTMallClass)mallClass;

- (id<YTMall>)getMallFromIdentifier:(NSString *)identifier;

// 获得一个Mall的首层
- (YTLocalFloor *)firstFloorFromMallLocalId:(NSString *)localDBId;
@end
