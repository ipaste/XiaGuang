//
//  YTMoreCategoryViewCell.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-18.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTCategory.h"
@class YTCategoryViewCell;

@interface YTMoreCategoryViewCell : UITableViewCell
-(id)initWithCategory:(YTCategory *)category reuseIdentifier:(NSString *)reuseIdentifier;
@end

