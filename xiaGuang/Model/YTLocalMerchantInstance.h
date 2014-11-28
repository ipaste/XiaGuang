//
//  YTLocalMerchantInstance.h
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "YTStaticResourceManager.h"
#import "YTLocalMall.h"
#import "YTMerchantLocation.h"
#import <AVOSCloud/AVOSCloud.h>
#define CLOUD_MERCHANT_CLASS_NAME @"Merchant2"
@interface YTLocalMerchantInstance : NSObject<YTMerchantLocation>

-(id)initWithDBResultSet:(FMResultSet *)findResultSet;

@end
