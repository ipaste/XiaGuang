//
//  YTBlock.h
//  HighGuang
//
//  Created by Yuan Tao on 10/9/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTMall.h"

@protocol YTBlock <NSObject>

@property(weak,nonatomic)NSString *blockName;
@property(weak,nonatomic)NSArray *floors;
@property(weak,nonatomic)id <YTMall> mall;

@end
