//
//  YTPreferential.h
//  虾逛
//
//  Created by YunTop on 15/2/5.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVObject.h"
@class YTCloudMerchant;
@interface YTPreferential : NSObject
@property (readonly ,nonatomic) NSString *identifier;
@property (readonly ,nonatomic) NSString *preferentialInfo;
@property (readonly ,nonatomic) NSNumber *originalPrice;
@property (readonly ,nonatomic) NSNumber *favorablePrice;
@property (readonly ,nonatomic) YTCloudMerchant *merchant;

- (instancetype)initWithCloudObject:(AVObject *)object;

- (void)getThumbnailWithCallBack:(void (^)(UIImage *result,NSError *error))callBack;
@end
