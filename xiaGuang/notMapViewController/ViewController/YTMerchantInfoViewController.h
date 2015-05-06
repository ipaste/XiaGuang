//
//  YTMerchantInfoViewController.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-19.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMerchant.h"
#import "YTH5ViewController.h"
@interface YTMerchantInfoViewController : UIViewController
-(id)initWithMerchant:(id <YTMerchant>)merchant;
@end
