//
//  YTMallmanageCell.h
//  虾逛
//
//  Created by Yuntop on 15/4/23.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMallDict.h"

@interface YTMallmanageCell : UITableViewCell
@property (strong ,nonatomic) YTCloudMall *mall;
/**
 *  设置Cell进度条的数值
 *
 *  @param value 数值 范围在0 ~ 1之间
 */
- (void)setProgress:(CGFloat)value;
- (void)stopDownload;
@end
