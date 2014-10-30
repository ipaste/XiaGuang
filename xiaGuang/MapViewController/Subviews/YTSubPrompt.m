//
//  YTSubPrompt.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-26.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSubPrompt.h"
@interface YTSubPrompt(){
    CGRect _frame;
    UILabel *_promptLabel;
    UIButton *_promptButton;
    UILabel *_subPromptLabel;
}
@end
@implementation YTSubPrompt

-(id)initWithFrame:(CGRect)frame{
    _frame = frame;
    frame.size.width =  0;
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0,CGRectGetWidth(_frame) - 120 , CGRectGetHeight(frame))];
        _promptLabel.textColor = [UIColor whiteColor];
        _promptLabel.font = [UIFont systemFontOfSize:15];
        
        _promptButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(_frame) - 55, 3, 50 , CGRectGetHeight(frame) - 6)];
        [_promptButton setTitle:@"跳转" forState:UIControlStateNormal];
        [_promptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _promptButton.layer.cornerRadius = 3.0;
        _promptButton.layer.borderWidth = 1.0;
        _promptButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _promptButton.layer.masksToBounds = YES;
        [_promptButton addTarget:self action:@selector(jumtoTarget:) forControlEvents:UIControlEventTouchUpInside];
        _promptButton.hidden = YES;
        
        _subPromptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
        _subPromptLabel.textAlignment = 1;
        _subPromptLabel.backgroundColor = [UIColor whiteColor];
        _subPromptLabel.layer.cornerRadius = 5.0;
        _subPromptLabel.layer.masksToBounds = YES;
        _subPromptLabel.font = [UIFont boldSystemFontOfSize:20];
        _subPromptLabel.alpha = 0;
        
        [self addSubview:_promptButton];
        [self addSubview:_promptLabel];
        
        self.hidden = YES;
    }
    return self;
}

-(void)subPromptShowAnimation{
    _isShow = YES;
    self.hidden = NO;
    [UIView animateWithDuration:.5 animations:^{
        _promptLabel.text = [NSString stringWithFormat:@"您已到 %@",self.floorName];
        self.frame = _frame;
    } completion:^(BOOL finished) {
        if (finished) {
            _promptButton.hidden = NO;
            _promptLabel.hidden = NO;
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat:1.0f];
            animation.repeatCount = 2;
            animation.duration = 2;
            [self.layer addAnimation:animation forKey:@"animationOpacity"];
        }
    }];
}
-(void)subPromptHideAnimation{
    _isShow = NO;
    _promptButton.hidden = YES;
    _promptLabel.hidden = YES;
    [UIView animateWithDuration:.5 animations:^{
        CGRect frame = self.frame;
        frame.size.width = 0;
        self.frame = frame;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
    
}
-(void)jumtoTarget:(UIButton *)sender{
    
    [self.delegate clickJumpToTarget];
}

-(void)showSubPromptLabelWithCompletion:(void (^)(BOOL finished))completion{
    _subPromptLabel.text = [NSString stringWithFormat:@"您已到 %@",self.floorName];
    _subPromptLabel.transform = CGAffineTransformIdentity;
    CGRect frame = _subPromptLabel.frame;
    frame.origin = CGPointMake(0, 80);
    _subPromptLabel.frame = frame;
    
    _subPromptLabel.alpha = 1;
    [UIView animateKeyframesWithDuration:.5 delay:1 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        _subPromptLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
        _subPromptLabel.center = CGPointMake(0, 0);
    } completion:^(BOOL finished) {
        if (completion != nil) {
            _subPromptLabel.alpha = 0;
            _promptButton.hidden = NO;
            _promptLabel.hidden = NO;
            completion(finished);
        }
    }];
    
}

@end
