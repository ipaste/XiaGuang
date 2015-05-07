//
//  YTMallActivity.h
//  虾逛
//
//  Created by Yuntop on 15/5/7.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "AVObject.h"


@class YTCloudMall;
@interface YTMallActivity : NSObject
@property (readonly ,nonatomic) NSString *identifier;

- (instancetype)initWithCloudObject:(AVObject *)object;
- (void)getMallInstanceWithCallBack:(void (^)(YTCloudMall * mall))callBack;
- (void)getActivityImgWithCallBack:(void (^)(UIImage *result,NSError *error))callBack;
@end
