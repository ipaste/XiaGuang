//
//  YTActiveDetailViewController.h
//  虾逛
//
//  Created by Yuntop on 15/5/14.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTStateView.h"
#import "YTMallActivity.h"
@interface YTActiveDetailViewController : UIViewController
@property (strong ,nonatomic) NSArray *activitys;
@property (nonatomic) NSInteger selectedActivity;
@end
