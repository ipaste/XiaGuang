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

#define MERCHANT_CLASS_NAME @"Merchant2"
#define MERCHANT_CLASS_MALL_KEY @"mall"
#define MERCHANT_CLASS_NAME_KEY @"name"
#define MERCHANT_CLASS_UNIID_KEY @"uniId"
#define MERCHANT_CLASS_SHORTNAME_KEY @"shortName"
#define MERCHANT_CLASS_ADDRESS_KEY @"address"
#define MERCHANT_CLASS_TYPE_KEY @"type"
#define MERCHANT_CLASS_ICON_KEY @"Icon"
#define MERCHANT_CLASS_FLOOR_KEY @"floor"


@interface YTCloudMerchant : NSObject<YTMerchant>

-(id)initWithAVObject:(AVObject *)object;
-(YTLocalMerchantInstance *)getLocalMerchantInstance;

@end
