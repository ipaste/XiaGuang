//
//  YTSwitchMallView.h
//  虾逛
//
//  Created by YunTop on 14/11/14.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTLocalMall.h"
#import "YTDBManager.h"
@interface YTSwitchMallView : UIView
@property (strong,nonatomic) id<YTMall> mall;
@end
