//
//  YTActiveDetailCell.m
//  虾逛
//
//  Created by Yuntop on 15/5/14.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTActiveDetailCell.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@implementation YTActiveDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self composeSubviews];
    }
    return self;
}

- (void)composeSubviews {
    self.backgroundColor = [UIColor colorWithString:@"ffffff"];
    
    //_imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 232.0)];
    //_imgView = [[UIImageView alloc]init];
    _imgView.backgroundColor = [UIColor clearColor];
    _imgView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.imgView];
    
    
//    _imgNumView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 53.0, 0.0, 53.0, 53.0)];
//    _imgNumView.backgroundColor = [UIColor clearColor];
//    _imgNumView.contentMode = UIViewContentModeScaleAspectFill;
//    [self addSubview:self.imgNumView];
//    
//    _activeLabel = [[UILabel alloc]initWithFrame:CGRectMake(15.0, CGRectGetMaxY(_imgView.frame) + 15.0, SCREEN_WIDTH - 30.0, 15.0f)];
//    _activeLabel.textColor = [UIColor colorWithString:@"333333"];
//    //_activeLabel.numberOfLines = 0;
//    _activeLabel.font = [UIFont systemFontOfSize:15.0];
//    [self addSubview:self.activeLabel];
//    
//    _dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(15.0, CGRectGetMaxY(_activeLabel.frame) + 12.0, 65.0f, 15.0f)];
//    _dateLabel.textColor = [UIColor colorWithString:@"666666"];
//    _dateLabel.font = [UIFont systemFontOfSize:14.0];
//    [self addSubview:self.dateLabel];
//    
//    _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_dateLabel.frame), CGRectGetMaxY(_activeLabel.frame) + 12.0, SCREEN_WIDTH - CGRectGetMaxX(_dateLabel.frame), 15.0f)];
//    _timeLabel.textColor = [UIColor colorWithString:@"e95e37"];
//    _timeLabel.font = [UIFont systemFontOfSize:15.0f];
//    [self addSubview:self.timeLabel];
}



@end
