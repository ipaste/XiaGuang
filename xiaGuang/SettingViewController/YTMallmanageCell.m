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
    UILabel *_sizeLabel;
    UIView *_lineView;
    UIImage *_currentImage;
    UIView *_selectView;
}

@end

@implementation YTMallmanageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.state = YTMallManageStateDownload;
        
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
        
        _sizeLabel = [[UILabel alloc]init];
        _sizeLabel.textColor = [UIColor colorWithString:@"aaaaaa"];
        _sizeLabel.font = [UIFont systemFontOfSize:12];
        
        [self addSubview:_selectView];
        [self addSubview:_progressLabel];
        [self addSubview:_mallLabel];
        [self addSubview:_downloadBtn];
        [self addSubview:_downloadPrg];
        [self addSubview:_lineView];
        [self addSubview:_sizeLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)layoutSubviews{
    CGSize textSize = [_progressLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame)) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_progressLabel.font} context:nil].size;
    CGSize nameSize = [_mallLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame)) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_mallLabel.font} context:nil].size;

    
    CGRect frame = _selectView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = CGRectGetWidth(self.frame);
    frame.size.height = CGRectGetHeight(self.frame);
    _selectView.frame = frame;
    
    frame = _mallLabel.frame;
    frame.origin.x = 26;
    frame.origin.y = 0;
    frame.size.width = nameSize.width;
    frame.size.height = CGRectGetHeight(self.frame);
    _mallLabel.frame = frame;
    
    frame = _sizeLabel.frame;
    frame.origin.x = CGRectGetMaxX(_mallLabel.frame) + 7;
    frame.size.width = 100;
    frame.size.height = CGRectGetHeight(_mallLabel.frame);
    _sizeLabel.frame = frame;
    
    frame = _progressLabel.frame;
    frame.origin.x = CGRectGetWidth(self.frame) - 26 - textSize.width;
    frame.origin.y = 0;
    frame.size.width = textSize.width + 20;
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
    frame.origin.x = CGRectGetWidth(self.frame) - 26 - _currentImage.size.width / 2;
    frame.origin.y = 0;
    frame.size.width = _currentImage.size.width;
    frame.size.height = _currentImage.size.height;
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
    if (_state == YTMallManageStateDownloaded) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(mallManageCell:downloadMallData:)]) {
        _downloadBtn.hidden = true;
        _progressLabel.hidden = false;
        _downloadPrg.hidden = false;
        [_delegate mallManageCell:self downloadMallData:self.mall];
    }
}

- (void)setProgress:(NSInteger)value{
    [UIView animateWithDuration:0.2 animations:^{
        _downloadPrg.progress = value / 120.0;
        _progressLabel.text = [NSString stringWithFormat:@"%.0lf%%",_downloadPrg.progress * 100];
    }];
    
    if (value == 120){
        self.state = YTMallManageStateDownloaded;
        [self stopDownload];
    }
}

- (void)stopDownload{
    _downloadBtn.hidden = false;
    _progressLabel.hidden = true;
    _downloadPrg.hidden = true;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    //_selectView.hidden = !selected;
}

-(void)setState:(YTMallManageState)state{
    switch (state) {
        case YTMallManageStateDownload:
            _currentImage = [UIImage imageNamed:@"icon_download"];
            break;
        case YTMallManageStateUpdata:
            _currentImage = [UIImage imageNamed:@"icon_refresh"];
            break;
        case YTMallManageStateDownloaded:
            _currentImage = [UIImage imageNamed:@"ico_downloaded"];
            break;
    }
    CGRect frame = _downloadBtn.frame;
    frame.size = _currentImage.size;
    _downloadBtn.frame = frame;
    [_downloadBtn setImage:_currentImage forState:UIControlStateNormal];
    _state = state;
}

-(void)setMall:(YTCloudMall *)mall{
    CGFloat size = [mall getMallFile].size;
    _mallLabel.text = [mall mallName];
    _sizeLabel.text = [NSString stringWithFormat:@"%.1fM",size / 1000000];
    [self setNeedsLayout];
    _mall = mall;
}


@end
