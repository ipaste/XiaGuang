//
//  YTActiveDetailCell.h
//  虾逛
//
//  Created by Yuntop on 15/5/14.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTActiveDetailCell : UITableViewCell

@property (nonatomic,strong)UIImageView *imgView; //大图
@property (nonatomic,strong)UIImageView *imgNumView; //序号图标
@property (nonatomic,strong)UILabel *activeLabel;
@property (nonatomic,strong)UILabel *dateLabel;
@property (nonatomic,strong)UILabel *timeLabel;


@end
