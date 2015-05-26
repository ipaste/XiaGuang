//
//  YTCloudMall.h
//  HighGuang
//
//  Created by Yuan Tao on 8/13/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud.h>
#import "YTMall.h"
#import "YTCloudFloor.h"
#import "YTLocalMall.h"
#import "AFNetWorking.h"
#import "YTCloudBlock.h"
#import "DPAPI.h"

#define MALL_CLASS_BIGTITLE_KEY @"mall_img_title"
#define MALL_CLASS_BIGBACKGROUND_KEY @"mall_img_background"
#define MALL_CLASS_LOCALID @"localId"
#define MALL_CLASS_REGION @"region"

@interface YTCloudMall : NSObject<YTMall,DPRequestDelegate>
@property (nonatomic) BOOL isLoading;

-(id)initWithAVObject:(AVObject *)object;
-(AVObject *)getCloudObj;
-(AVFile *)getMallFile;
-(YTLocalMall *)getLocalCopy DEPRECATED_ATTRIBUTE;
@end
