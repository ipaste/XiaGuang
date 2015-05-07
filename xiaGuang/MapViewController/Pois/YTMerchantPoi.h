//
//  YTMerchantPoi.h
//  HighGuang
//
//  Created by Yuan Tao on 10/17/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTPoi.h"
#import "YTMerchantLocation.h"
#import "YTMerchantAnnotation.h"
@interface YTMerchantPoi : YTPoi

-(id)initWithMerchantInstance:(id<YTMerchantLocation>)merchantLocation;

@end
