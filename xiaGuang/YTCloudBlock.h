//
//  YTCloudBlock.h
//  HighGuang
//
//  Created by Yuan Tao on 10/9/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTBlock.h"
#import <AVOSCloud.h>
#import "YTCloudMall.h"

#define BLOCK_CLASS_MALL_KEY @"mall"
#define BLOCK_CLASS_BLOCKNAME_KEY @"blockName"

@interface YTCloudBlock : NSObject<YTBlock>

-(id)initWithAVObject:(AVObject *)object;

@end
