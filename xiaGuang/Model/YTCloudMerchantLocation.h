//
//  YTCloudMerchantLocation.h
//  HighGuang
//
//  Created by Yuan Tao on 8/14/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMerchantLocation.h"
#import <AVOSCloud/AVOSCloud.h>


#define MERCHANTLOCATION_CLASS_NAME @"MerchantLocation"
#define MERCHANTLOCATION_CLASS_MALL_KEY @"mall"
#define MERCHANTLOCATION_CLASS_NAME_KEY @"name"
#define MERCHANTLOCATION_CLASS_MAJORAREA_KEY @"majorArea"
#define MERCHANTLOCATION_CLASS_MERCHANT_KEY @"merchant"
#define MERCHANTLOCATION_CLASS_FLOOR_KEY @"floor"
#define MERCHANTLOCATION_CLASS_X_KEY @"x"
#define MERCHANTLOCATION_CLASS_Y_KEY @"y"
#define MERCHANTLOCATION_CLASS_DISPLAYLEVEL_KEY @"displayLevel"
#define MERCHANTLOCATION_CLASS_ADDRESS_KEY @"address"
#define MERCHANTLOCATION_CLASS_INMINORAREA_KEY @"inMinorArea"



@interface YTCloudMerchantLocation : NSObject<YTMerchantLocation>

-(id)initWithAVObject:(AVObject *) object;

@end
