//
//  YTMallCell.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-11.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMall.h"
@interface YTMallCell : UITableViewCell<UIScrollViewDelegate>
@property (weak,nonatomic) id <YTMall> mall;
@end
