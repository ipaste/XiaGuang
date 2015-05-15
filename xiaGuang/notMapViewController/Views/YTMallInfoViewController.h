//
//  YTMerchantIndexViewController.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMallDict.h"
#import "YTMallPositionViewController.h"
#import "YTPreferential.h"

#import "YTMallActivity.h"
#import "YTSaleView.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTMoreCategoryViewController.h"
#import "YTMajorArea.h"
#import "YTCloudMerchant.h"
#import "YTCategory.h"
#import "YTDataManager.h"
#import "YTSearchView.h"
#import "YTMerchantViewCell.h"
#import "YTMerchantInfoViewController.h"
#import "YTResultsViewController.h"
#import "YTMapViewController2.h"
#import "YTStateView.h"
#import "YTadScrollAndPageView.h"
#import "YTActiveDetailViewController.h"
@interface YTMallInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,YTSearchViewDelegate,YTSaleDelegate,UIScrollViewDelegate,YTscrollViewDelegate>
- (instancetype)initWithMallIdentify:(NSString *)identify;
@end
