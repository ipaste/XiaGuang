//
//  YTStateView.m
//  虾逛
//
//  Created by Silence on 15/4/15.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTStateView.h"

#define DEFAULT_SIZE 100

@interface YTStateView(){
    UIImageView *_showImageView;
    UILabel *_promptLable;
    UIView *_backgroundView;
}
@end

@implementation YTStateView

#pragma Mark Initialization Method
- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithStateType:YTStateTypeNormal];
}

- (instancetype)initWithStateType:(YTStateType)type{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _promptLable = [[UILabel alloc]init];
        _promptLable.font = [UIFont systemFontOfSize:14];
        _promptLable.textAlignment = 1;
        _promptLable.textColor = [UIColor colorWithString:@"999999"];
        [self addSubview:_promptLable];
        
        _backgroundView = [[UIView alloc]init];
        _backgroundView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
        [self addSubview:_backgroundView];
        
        self.type = type;
        self.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
    }
    return self;
}

- (void)layoutSubviews{
    _showImageView.center = CGPointMake(self.center.x, _showImageView.center.y);
    
    CGRect frame = _promptLable.frame;
    frame.origin.y = CGRectGetMaxY(_showImageView.frame) + 8;
    frame.size.width = CGRectGetWidth(self.frame);
    frame.size.height = 15;
    _promptLable.frame = frame;
    
    frame = _backgroundView.frame;
    frame = self.bounds;
    _backgroundView.frame = frame;
}

- (UIImageView *)changeCurrntShowWithType:(YTStateType)type{
    UIImageView *showImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 110, DEFAULT_SIZE, DEFAULT_SIZE)];
    switch (type) {
        case YTStateTypeNormal:
            break;
        case YTStateTypeLoading:
        {
            NSMutableArray *images = [NSMutableArray new];
            for (int index = 0; index <= 10; index++) {
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"loading_%d",index]];
                [images addObject:image];
            }
            showImageView.animationImages = images;
            showImageView.animationDuration = 1.7;
            _promptLable.text = @"玩命加载中...";
        }
            break;
        case YTStateTypeNotFound:
            showImageView.image = [UIImage imageNamed:@"icon_non_content"];
            _promptLable.text = @"很抱歉,无搜索结果";
            break;
        case YTStateTypeNoNetWork:
            showImageView.image = [UIImage imageNamed:@"icon_non_wifi"];
            _promptLable.text = @"网络不给力";
            break;
    }
    _type = type;
    return showImageView;
}

-(void)setType:(YTStateType)type{
    [_showImageView removeFromSuperview];
    _showImageView = [self changeCurrntShowWithType:type];
    [self addSubview:_showImageView];
    _type = type;
}

- (void)startAnimation{
    if (_type == YTStateTypeLoading) {
        _showImageView.alpha = 1;
        [_showImageView startAnimating];
    }
}
- (void)stopAnimation{
    if (_type = YTStateTypeLoading) {
        _showImageView.alpha = 0;
        [_showImageView stopAnimating];
    }
}


-(void)dealloc{
    [_showImageView stopAnimating];
    [_showImageView removeFromSuperview];
}
@end
