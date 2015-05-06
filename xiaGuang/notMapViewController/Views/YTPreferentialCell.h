//
//  YTPreferentialCell.h
//  虾逛
//
//  Created by YunTop on 15/2/5.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPreferential.h"
typedef NS_ENUM(NSInteger, YTPreferentialCellStyle) {
    YTPreferentialCellStyleSole,
    YTPreferentialCellStyleOther
};
@interface YTPreferentialCell : UITableViewCell
@property (strong ,nonatomic) YTPreferential *preferential;
@property (nonatomic) YTPreferentialCellStyle style;
@end