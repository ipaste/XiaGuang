//
//  YTMerchant.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-5.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "YTFloor.h"
@protocol YTMerchant <NSObject>

@property(weak,nonatomic)NSString *mercantId;
@property (weak,nonatomic) NSString *merchantName;
@property (weak,nonatomic) NSString *shortName;
@property (weak,nonatomic) NSString *address;
@property (weak,nonatomic) NSArray *type;
@property (weak,nonatomic) UIImage *icon;
@property (weak,nonatomic) NSString *localDBId;
@property (weak,nonatomic) id<YTFloor> floor;
@property (strong,nonatomic) id<YTMall> mall;

-(void)getThumbNailWithCallBack:(void (^)(UIImage *result,NSError *error))callback;

-(id)copy;

@end
