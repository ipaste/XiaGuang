//
//  YTMallMerchantBundle.h
//  HighGuang
//
//  Created by Yuan Tao on 10/14/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTMall.h"
#import "YTMerchant.h"
#import "YTCloudMerchant.h"
#import <AVOSCloud/AVQuery.h>

@interface YTMallMerchantBundle : NSObject

-(id)initWithMall:(id<YTMall>)mall;

-(void)mallInfoTitleWithCallBack:(void (^)(UIImage *result,NSError* error))callback;
-(void)mallBackgroundWithCallBack:(void (^)(UIImage *result,NSError* error))callback;

@property (readonly,nonatomic) UIImage *mallInfoImage;
@property (readonly,nonatomic) UIImage *mallBackgroundImage;
@property (readonly,nonatomic) BOOL mallInfoImageReady;
@property (readonly,nonatomic) BOOL mallBackgroundImageReady;
@property (readonly,nonatomic) BOOL merchantsIconReady;
@property (readonly,nonatomic) NSArray *icons;
@property (readonly,nonatomic) NSArray *merchants;



@end
