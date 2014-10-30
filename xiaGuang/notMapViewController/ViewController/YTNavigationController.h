//
//  YTNavtgationController.h
//  xiaGuang
//
//  Created by YunTop on 14/10/29.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTHomeViewController.h"
#import "YTMallInfoViewController.h"
#import "YTSettingViewController.h"
#import "YTMallViewController.h"

@interface YTNavigationController : UINavigationController<UINavigationControllerDelegate>
-(instancetype)initWithCreateHomeViewController;
@end
