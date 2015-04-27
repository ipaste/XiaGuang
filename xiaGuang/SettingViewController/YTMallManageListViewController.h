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

@interface YTMallManageListViewController : UIViewController

@property (nonatomic, assign) NSInteger selectedTabID;
@property (nonatomic, assign) BOOL isLeft;                              // 向左滚动

@end
