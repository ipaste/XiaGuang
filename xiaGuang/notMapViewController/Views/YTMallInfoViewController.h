//
//  YTMerchantIndexViewController.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMall.h"
#import "YTMallPositionView.h"
#import "YTMallPosistionViewController.h"
#import "YTPreferential.h"
@interface YTMallInfoViewController : UIViewController
@property (weak,nonatomic) id<YTMall> mall;
@property (nonatomic) BOOL isPreferential;
@end
