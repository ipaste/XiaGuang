//
//  YTLoadingView.m
//  虾逛
//
//  Created by YunTop on 14/12/2.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTLoadingView.h"

@implementation YTLoadingView{
    UIActivityIndicatorView *_acitvityView;
    UILabel *_textLabel;
}
-(instancetype)initWithPosistion:(CGPoint)posistion{
    self = [super initWithFrame:CGRectMake(posistion.x, posistion.y, CGRectGetWidth([UIScreen mainScreen].bounds), 50)];
    if (self) {
        _acitvityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _acitvityView.hidden = YES;
        [self addSubview:_acitvityView];
        
        _textLabel = [[UILabel alloc]init];
        _textLabel.hidden = YES;
        [self addSubview:_textLabel];
    }
    return self;
}


-(void)layoutSubviews{
    CGRect frame = _acitvityView.frame;
    frame.origin.x = CGRectGetWidth(self.frame) / 2 - 50;
    frame.origin.y = 15;
    _acitvityView.frame = frame;
    
    frame = _textLabel.frame;
    frame.origin.x = CGRectGetMaxX(_acitvityView.frame) + 5;
    frame.origin.y = CGRectGetMinY(_acitvityView.frame);
    frame.size.width = 84;
    frame.size.height = CGRectGetHeight(_acitvityView.frame);
    _textLabel.frame = frame;
    
    _textLabel.text = @"正在加载数据";
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.font = [UIFont systemFontOfSize:14];
    
}

-(void)start{
    _acitvityView.hidden = NO;
    _textLabel.hidden = NO;
    [_acitvityView startAnimating];
}
-(void)stop{
    [_acitvityView stopAnimating];
    _acitvityView.hidden = YES;
    _textLabel.hidden = YES;
}
@end
