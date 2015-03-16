//
//  YTCloudMall.h
//  HighGuang
//
//  Created by Yuan Tao on 8/13/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMall.h"
#import <AVOSCloud.h>
#import "YTCloudFloor.h"
#import "YTLocalMall.h"
#import "AFNetWorking.h"
#import "YTCloudBlock.h"
#import "DPAPI.h"

#define MALL_CLASS_BIGTITLE_KEY @"mall_img_title"
#define MALL_CLASS_BIGBACKGROUND_KEY @"mall_img_background"
#define MALL_CLASS_LOCALID @"localId"

@interface YTCloudMall : NSObject<YTMall,DPRequestDelegate>

-(id)initWithAVObject:(AVObject *)object;
-(AVObject *)getCloudObj;
-(YTLocalMall *)getLocalCopy;
@end
