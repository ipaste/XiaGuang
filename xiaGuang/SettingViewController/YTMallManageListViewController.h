//
//  YTMallManageListViewController.h
//  虾逛
//
//  Created by Nov_晓 on 15/4/20.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVObject.h>
#import <AVQuery.h>
#import "YTCityAndRegion.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTMallmanageCell.h"
#import "YTMallDict.h"
#import "YTMessageBox.h"

@interface YTMallManageListViewController : UIViewController<YTMallManageDelegate>
+ (instancetype)shareMallListController;
@end
