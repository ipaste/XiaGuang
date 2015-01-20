//
//  YTMerchantViewCell.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMerchant.h"
@interface YTMerchantViewCell : UITableViewCell
@property (strong,nonatomic) id<YTMerchant> merchant;
@property (strong,nonatomic) UIColor *titleColor;
@end
