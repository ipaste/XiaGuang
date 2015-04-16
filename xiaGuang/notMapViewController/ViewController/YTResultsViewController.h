//
//  YTResultsViewController.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVObject.h>
#import <AVQuery.h>
#import "YTMerchantViewCell.h"
#import "YTCloudMerchant.h"
#import "YTCategoryResultsView.h"
#import "YTPreferential.h"
#import "YTCategory.h"
#import "YTStateView.h"
#import "MJRefresh.h"
#import "YTMallDict.h"
#import "Reachability.h"
#import "YTMerchantInfoViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"

@interface YTResultsViewController : UIViewController

-(instancetype)initWithPreferntialInMall:(id <YTMall>)mall;

-(instancetype)initWithSearchInMall:(id<YTMall>)mall
                       andResutsKey:(NSString *)key;

-(instancetype)initWithSearchInMall:(id<YTMall>)mall
                       andResutsKey:(NSString *)key
                          andSubKey:(NSString *)subKey;

-(instancetype)initWithSearchInMall:(id<YTMall>)mall
               andResultsLocalDBIds:(NSArray *)ids;
@end
