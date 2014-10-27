//
//  YTFloor.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-5.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTBlock.h"
@protocol YTFloor <NSObject>

@property(weak,nonatomic)NSString *identifier;
@property(weak,nonatomic)NSString *floorName;
@property(weak,nonatomic)NSArray *majorAreas;
@property(weak,nonatomic)id <YTBlock> block;

@end
