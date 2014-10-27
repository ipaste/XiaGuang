//
//  YTPanel.m
//  xiaGuang
//
//  Created by YunTop on 14-10-24.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTPanel.h"
#define BUTTONSIZE 60
#define SPACING 20
@implementation YTPanel{
    UIView *_background;
    UIView *_circle;
    NSMutableArray *_items;
    
}
-(instancetype)initWithFrame:(CGRect)frame items:(NSArray *)itmes{
    self = [super initWithFrame:frame];
    if (self) {
        _background = [[UIView alloc]initWithFrame:self.bounds];
        [self addSubview:_background];
        _circle = [[UIView alloc]initWithFrame:CGRectMake(40, 40, CGRectGetWidth(frame) - 80, CGRectGetHeight(frame) - 80)];
       //[_background addSubview:_circle];
        
        _items = [NSMutableArray array];
        
        for (int i = 0 ; i < itmes.count; i++) {
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, BUTTONSIZE, BUTTONSIZE)];
            [button setTitle:itmes[i] forState:UIControlStateNormal];
            button.layer.cornerRadius = BUTTONSIZE / 2;
            button.backgroundColor = [UIColor redColor];
            button.tag = i;
            [button addTarget:self action:@selector(clickToButton:) forControlEvents:UIControlEventTouchUpInside];
            [_background addSubview:button];
            [_items addObject:button];
        }
        [self setButtonPosition];
    }
    return self;
}

-(void)layoutSubviews{
    
    _circle.layer.cornerRadius = CGRectGetHeight(_circle.frame) / 2;
    _circle.layer.borderWidth = 1;
    _circle.layer.borderColor = [UIColor blackColor].CGColor;
    
    _background.backgroundColor = [UIColor blueColor];
    _background.layer.cornerRadius = CGRectGetWidth(_background.frame) / 2;
}

-(void)setItemsTheImage:(NSArray *)images{

}

-(void)setButtonPosition{
    CGFloat centerX = CGRectGetWidth(self.bounds) / 2;
    CGFloat centerY = CGRectGetHeight(self.bounds) / 2;
    NSArray *points = @[[NSValue valueWithCGPoint:CGPointMake(centerX, CGRectGetMinX(self.bounds) + SPACING + BUTTONSIZE / 2)],[NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.bounds) - SPACING - BUTTONSIZE / 2 , centerY)],[NSValue valueWithCGPoint:CGPointMake(centerX, CGRectGetHeight(self.bounds)- SPACING - BUTTONSIZE / 2)],[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.bounds) + BUTTONSIZE / 2 + SPACING, centerY)]];
    for (int i = 0 ; i < _items.count; i++) {
        UIButton *tmpButton = _items[i];
        tmpButton.center = [points[i] CGPointValue];
        
    }
}

-(void)clickToButton:(UIButton *)sender{
    CGRect frame = sender.frame;
    [UIView animateWithDuration:.5 animations:^{
        for (UIButton *tmpButton in _items) {
            if (![tmpButton isEqual:sender]) {
                tmpButton.alpha = 0;
            }
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.5 animations:^{
            sender.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
        } completion:^(BOOL finished) {
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(5.0, 5.0, 1.0)];
            scaleAnimation.duration = .5;
            scaleAnimation.repeatCount = 1;
            scaleAnimation.delegate = self;
            [scaleAnimation setValue:[NSValue valueWithCGRect:frame] forKey:@"Identity"];
            [scaleAnimation setValue:sender forKey:@"animtionWithObject"];
            [sender.layer addAnimation:scaleAnimation forKey:@"scale"];
        }];
    }];
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        UIButton *currentButton = [anim valueForKey:@"animtionWithObject"];
         CGRect frame = [[anim valueForKey:@"Identity"] CGRectValue];
        if ([self.delegate respondsToSelector:@selector(clickedPanelAtIndex:)]) {
            [self.delegate clickedPanelAtIndex:currentButton.tag];
        }
        currentButton.frame = frame;
        for (UIButton *tmpButton in _items) {
            if (![tmpButton isEqual:currentButton]) {
                tmpButton.alpha = 1;
            }
        }
    }
}
@end
