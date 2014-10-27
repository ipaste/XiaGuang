//
//  YTSelectCategoryViewCell.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-22.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTCategory.h"
@interface YTSelectCategoryViewCell : UITableViewCell
@property (strong,nonatomic)YTCategory *category;
@property (nonatomic)BOOL isSelect;
@end
