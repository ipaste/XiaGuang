//
//  YTMallmanageCell.m
//  虾逛
//
//  Created by Yuntop on 15/4/23.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#import "YTMallmanageCell.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"

@interface YTMallmanageCell (){
    UILabel *mallLabel;               // 商城名称
    UIButton *downloadBtn;            // 下载按钮
    UIProgressView *downloadPrg;      // 下载进度条
}

@end

@implementation YTMallmanageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self composeSubView];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)composeSubView {
    self.backgroundColor = [UIColor clearColor];
    
    mallLabel = [[UILabel alloc]initWithFrame:CGRectMake(26.0f, 20.0f, 180.0f, 20.0f)];
    mallLabel.textColor = [UIColor colorWithString:@"333333"];
    mallLabel.font = [UIFont systemFontOfSize:15];
    
    downloadBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 26.0f - 30.0f, 18.0f, 30.0f, 20.0f)];
    downloadBtn.backgroundColor =  [UIColor clearColor];
    [downloadBtn setImage:[UIImage imageNamed:@"icon_download"] forState:UIControlStateNormal];
    
    downloadPrg = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    downloadPrg.frame = CGRectMake(mallLabel.frame.size.width + 26.0f, 25.0, 50.0f, 50.0f);
    downloadPrg.progressTintColor = [UIColor orangeColor];
    downloadPrg.progress = 0.3;
    
    
    [self addSubview:mallLabel];
    [self addSubview:downloadBtn];
    [self addSubview:downloadPrg];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
