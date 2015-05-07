//
//  YTCloudMerchant.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-17.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTCloudMall.h"
#import "YTMerchant.h"
#import "YTFloor.h"
#import "YTLocalMerchantInstance.h"

#define MERCHANT_CLASS_NAME @"Merchant"
#define MERCHANT_CLASS_MALL_KEY @"mall"
#define MERCHANT_CLASS_NAME_KEY @"name"
#define MERCHANT_CLASS_UNIID_KEY @"uniId"
#define MERCHANT_CLASS_SHORTNAME_KEY @"shortName"
#define MERCHANT_CLASS_ADDRESS_KEY @"address"
#define MERCHANT_CLASS_TYPE_KEY @"type"
#define MERCHANT_CLASS_ICON_KEY @"Icon"
#define MERCHANT_CLASS_FLOOR_KEY @"floor"

@interface YTCloudMerchant : NSObject<YTMerchant,DPRequestDelegate>
@property (assign ,nonatomic)BOOL isSole;
@property (assign ,nonatomic)BOOL isOther;


-(id)initWithAVObject:(AVObject *)object;
-(YTLocalMerchantInstance *)getLocalMerchantInstance;

- (void)merchantWithPreferentials:(void(^)(NSArray *preferentials,NSError *error))callBack DEPRECATED_ATTRIBUTE;

- (void)getSolePreferentials:(void (^)(NSArray *preferentials,NSError *error))callBack;
- (void)getOtherPreferentials:(void (^)(NSArray *preferentials,NSError *error))callBack;
@end
