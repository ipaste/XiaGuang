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
    UILabel *_mallLabel;               // 商城名称
    UIButton *_downloadBtn;            // 下载按钮
    UIProgressView *_downloadPrg;      // 下载进度条
    UILabel *_progressLabel;
    UIView *_lineView;
    UIImage *_downloadImage;
    UIView *_selectView;
}

@end

@implementation YTMallmanageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _downloadImage = [UIImage imageNamed:@"icon_download"];
        
        _selectView = [[UIView alloc]init];
        _selectView.backgroundColor = [UIColor colorWithString:@"000000" alpha:0.1];
        _selectView.hidden = true;
        
        _mallLabel = [[UILabel alloc]init];
        _mallLabel.textColor = [UIColor colorWithString:@"333333"];
        _mallLabel.font = [UIFont systemFontOfSize:15];
        
        _downloadBtn = [[UIButton alloc]init];
        _downloadBtn.backgroundColor =  [UIColor clearColor];
        [_downloadBtn addTarget:self action:@selector(downloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_downloadBtn setImage:[UIImage imageNamed:@"icon_download"] forState:UIControlStateNormal];
        
        _progressLabel = [[UILabel alloc]init];
        _progressLabel.text = @"0%";
        _progressLabel.hidden = true;
        _progressLabel.font = [UIFont systemFontOfSize:12];
        _progressLabel.textColor = [UIColor colorWithString:@"e95e37"];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        
        _downloadPrg = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _downloadPrg.progressTintColor = [UIColor orangeColor];
        _downloadPrg.hidden = true;
        _downloadPrg.progress = 0.0;
        
        
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = [UIColor colorWithString:@"b2b2b2"];
        
        [self addSubview:_selectView];
        [self addSubview:_progressLabel];
        [self addSubview:_mallLabel];
        [self addSubview:_downloadBtn];
        [self addSubview:_downloadPrg];
        [self addSubview:_lineView];
        
        //self.selectedBackgroundView = _selectView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)layoutSubviews{
    CGSize textSize = [_progressLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame)) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_progressLabel.font} context:nil].size;
    
    
    CGRect frame = _selectView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = CGRectGetWidth(self.frame);
    frame.size.height = CGRectGetHeight(self.frame);
    _selectView.frame = frame;
    
    frame = _mallLabel.frame;
    frame.origin.x = 26;
    frame.origin.y = 0;
    frame.size.width = CGRectGetWidth(self.frame) / 2;
    frame.size.height = CGRectGetHeight(self.frame);
    _mallLabel.frame = frame;
    
    frame = _progressLabel.frame;
    frame.origin.x = CGRectGetWidth(self.frame) - 26 - textSize.width;
    frame.origin.y = 0;
    frame.size.width = textSize.width;
    frame.size.height = CGRectGetHeight(self.frame);
    _progressLabel.frame = frame;
    
    frame = _downloadPrg.frame;
    frame.origin.x = CGRectGetMinX(_progressLabel.frame) - 65;
    frame.origin.y = 0;
    frame.size.width = 60;
    frame.size.height = 5;
    _downloadPrg.frame = frame;
    _downloadPrg.center = CGPointMake(_downloadPrg.center.x, CGRectGetHeight(self.frame) / 2);
    
    frame = _downloadBtn.frame;
    frame.origin.x = CGRectGetWidth(self.frame) - 26 - _downloadImage.size.width / 2;
    frame.origin.y = 0;
    frame.size.width = _downloadImage.size.width;
    frame.size.height = _downloadImage.size.height;
    _downloadBtn.frame = frame;
    [_downloadBtn setCenter:CGPointMake(_downloadBtn.center.x, CGRectGetHeight(self.frame) / 2)];
    
    frame = _lineView.frame;
    frame.origin.x = 10;
    frame.origin.y = CGRectGetHeight(self.frame) - 0.5;
    frame.size.width = CGRectGetWidth(self.frame) - 20;
    frame.size.height = 0.5;
    _lineView.frame = frame;
    
    
}

- (void)downloadButtonClicked:(UIButton *)sender{
    NSLog(@"开始下载");
    _downloadBtn.hidden = true;
    _progressLabel.hidden = false;
    _downloadPrg.hidden = false;
}

- (void)setProgress:(CGFloat)value{
    _downloadPrg.progress = value;
    _progressLabel.text = [NSString stringWithFormat:@"%d%%",(int)value * 100];
}

- (void)stopDownload{
    
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    //_selectView.hidden = !selected;
}

-(void)setMall:(YTCloudMall *)mall{
    _mallLabel.text = [mall mallName];
    _mall = mall;
}


@end
