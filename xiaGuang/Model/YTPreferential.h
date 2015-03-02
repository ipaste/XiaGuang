//
//  YTPreferential.h
//  虾逛
//
//  Created by YunTop on 15/2/5.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVObject.h"
#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSInteger, YTPreferentialType) {
    YTPreferentialTypeSole,
    YTPreferentialTypeOther
};

@class YTCloudMerchant;
@interface YTPreferential : NSObject
@property (readonly ,nonatomic) NSString *identifier;
@property (readonly ,nonatomic) NSString *preferentialInfo;
@property (readonly ,nonatomic) NSNumber *originalPrice;
@property (readonly ,nonatomic) NSNumber *favorablePrice;
@property (readonly ,nonatomic) NSString *time;
@property (readonly ,nonatomic) YTPreferentialType type;


- (instancetype)initWithCloudObject:(AVObject *)object;
- (instancetype)initWithDaZhongDianPing:(NSDictionary *)dictionary;
- (void)getThumbnailWithCallBack:(void (^)(UIImage *result,NSError *error))callBack;
- (void)getMerchantInstanceWithCallBack:(void (^)(YTCloudMerchant * merchant))callBack;
@end
