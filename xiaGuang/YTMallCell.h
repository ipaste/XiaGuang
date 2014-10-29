//
//  YTMallCell.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-11.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMall.h"
#import "YTMerchant.h"
#import "YTMallMerchantBundle.h"

@protocol YTMallDelegate <NSObject>
-(void)selectMerchant:(id<YTMerchant>)merchant;
@end

@interface YTMallCell : UITableViewCell<UIScrollViewDelegate>
@property (weak,nonatomic) id<YTMallDelegate> delegate;
@property (nonatomic,weak) YTMallMerchantBundle *mallMerchantBundle;
@end
