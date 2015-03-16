//
//  YTEndNavigatingView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-10.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMessageBox.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"

typedef void(^YTMessageBoxCallBack)(NSInteger tag);
@interface YTMessageBox(){
    UILabel *_titleLable;
    UILabel *_messageLabel;
    UIImageView *_backgroundView;
    UIButton *_cancelButton;
    UIButton *_enterButton;
   __weak UIWindow *_window;
    YTMessageBoxCallBack tmpCallBack;
}
@end
@implementation YTMessageBox
-(id)initWithTitle:(NSString *)title Message:(NSString *)message{
    return [self initWithTitle:title Message:message cancelButtonTitle:nil];
}

-(id)initWithTitle:(NSString *)title Message:(NSString *)message cancelButtonTitle:(NSString *)buttonTitle{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [self initUiWith:title Message:message cancelButtonTitle:buttonTitle];
        tmpCallBack = nil;

    }
    return self;
}
-(void)initUiWith:(NSString *)title Message:(NSString *)message cancelButtonTitle:(NSString *)buttonTitle{
    
    _window = [[UIApplication sharedApplication].delegate window];
    _backgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 240, 170)];
    _backgroundView.userInteractionEnabled = YES;
    _backgroundView.center = self.center;
    _backgroundView.image = [UIImage imageNamed:@"nav_bg_pop"];
    [self addSubview:_backgroundView];
    
    _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(_backgroundView.frame), 20)];
    _titleLable.text = title;
    _titleLable.textAlignment = 1;
    _titleLable.font = [UIFont systemFontOfSize:17];
    _titleLable.textColor = [UIColor colorWithString:@"e95e37"];
    [_backgroundView addSubview:_titleLable];
    
    _messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_titleLable.frame) + 10, CGRectGetWidth(_titleLable.frame) - 20, CGRectGetHeight(_titleLable.frame) * 2)];
    _messageLabel.text = message;
    _messageLabel.numberOfLines = 2;
    _messageLabel.lineBreakMode = 0;
    _messageLabel.font = [UIFont systemFontOfSize:15];
    _messageLabel.textColor = [UIColor colorWithString:@"303030"];
    _messageLabel.textAlignment = 1;
    [_backgroundView addSubview:_messageLabel];
    CGRect frame = CGRectMake(20, CGRectGetHeight(_backgroundView.frame) - 60, 95, 40);
    NSString *cancelTitle = @"取消";
    if (buttonTitle == nil || buttonTitle.length <= 0) {
        _enterButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(frame) + 10, CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _enterButton.tag = 1;
        [_enterButton setBackgroundImage:[UIImage imageNamed:@"nav_btn_pop_yes_pr"] forState:UIControlStateHighlighted];
        [_enterButton setBackgroundImage:[UIImage imageNamed:@"nav_btn_pop_yes_un"] forState:UIControlStateNormal];
        [_enterButton setTitle:@"确定" forState:UIControlStateNormal];
        [_enterButton setTitleColor:[UIColor colorWithString:@"e95e37"] forState:UIControlStateNormal];
        [_enterButton addTarget:self action:@selector(clickToButton:) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_enterButton];
    }else{
        cancelTitle = buttonTitle;
        frame.size.width = CGRectGetWidth(_backgroundView.frame) - 40;
    }
    _cancelButton = [[UIButton alloc]initWithFrame:frame];
    _cancelButton.tag = 0;
    [_cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"nav_btn_pop_no_un"] forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor colorWithString:@"404040"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(clickToButton:) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:_cancelButton];
    
    
}

-(void)setMessageColor:(UIColor *)messageColor{
    _messageLabel.textColor = messageColor;
    _messageColor = messageColor;
}
-(void)show{
    [_window addSubview:self];
}

-(void)callBack:(void(^)(NSInteger tag))callBack{
    tmpCallBack = callBack;
}

-(void)clickToButton:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(clickToButtonAtTag:)]) {
        [self.delegate clickToButtonAtTag:sender.tag];
    }
    
    if (tmpCallBack != nil) {
         tmpCallBack(sender.tag);
    }
    if (_window != nil) {
        [self removeFromSuperview];
    }
    
    
}

@end
