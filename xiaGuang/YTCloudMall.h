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
//#import "YTLocalMall.h"
#import "YTCloudBlock.h"

#define MALL_CLASS_LOGO_KEY @"mallNameLogo"
#define MALL_CLASS_BACKGROUND_KEY @"MallBackground"
#define MALL_CLASS_INFO_KEY @"MallInfoBackground"
#define MALL_CLASS_INFOIMAGE_KEY @"mallInfoTitleImage"
#define MALL_CLASS_LONGITUDE_KEY @"longitude"
#define MALL_CLASS_LATITUDE_KEY @"latitude"

@interface YTCloudMall : NSObject<YTMall>

-(id)initWithAVObject:(AVObject *)object;
-(AVObject *)getCloudObj;
//-(YTLocalMall *)getLocalCopy;

@end
