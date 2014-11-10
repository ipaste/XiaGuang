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

@property(strong,nonatomic)NSString *blockName;
@property(strong,nonatomic)NSArray *floors;
@property(strong,nonatomic)id <YTMall> mall;

@end
