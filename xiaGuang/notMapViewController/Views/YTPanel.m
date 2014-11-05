//
//  YTPanel.m
//  xiaGuang
//
//  Created by YunTop on 14-10-24.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTPanel.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import <POP.h>
#define BUTTON_SIZE 80
#define INNER_CIRCLE 160
#define SPACING 17.5
@implementation YTPanel{
    UIImageView *_background;
    UIImageView *_circle;
    UIImageView *_bluetooth;
    UIImageView *_selectedImageView;
    NSMutableArray *_items;
    UIView *_topLine;
    UIView *_rightLine;
    UIView *_bottomLine;
    UIView *_leftLine;
}
-(instancetype)initWithFrame:(CGRect)frame items:(NSArray *)itmes{
    self = [super initWithFrame:frame];
    if (self) {
        _background = [[UIImageView alloc]initWithFrame:self.bounds];
        _background.image = [UIImage imageNamed:@"home_img_bigcircle"];
        [self addSubview:_background];
        
        _circle = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, INNER_CIRCLE, INNER_CIRCLE)];
        _circle.image = [UIImage imageNamed:@"home_img_smallcircle"];
       [self addSubview:_circle];

        _bluetooth = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
        [self setBluetoothState:NO];
        [self addSubview:_bluetooth];
        
        _items = [NSMutableArray array];
        
        for (int i = 0 ; i < itmes.count; i++) {
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE)];
            [button setTitle:itmes[i] forState:UIControlStateNormal];
            button.layer.cornerRadius = BUTTON_SIZE / 2;
            [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(30,0, 0, 0)];
            button.tag = i;
            [button addTarget:self action:@selector(clickToButton:) forControlEvents:UIControlEventTouchUpInside];
            [button pop_animationForKey:@"move"];
            [self addSubview:button];
            [_items addObject:button];
        }
        [self setButtonPosition];
        
        //line
        _topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 29)];
        _topLine.backgroundColor = [UIColor colorWithString:@"6d6d6d"];
        [self insertSubview:_topLine atIndex:0];
        _rightLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 29, 1)];
        _rightLine.backgroundColor = [UIColor colorWithString:@"6d6d6d"];
        [self insertSubview:_rightLine atIndex:0];
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 29)];
        _bottomLine.backgroundColor = [UIColor colorWithString:@"6d6d6d"];
        [self insertSubview:_bottomLine atIndex:0];
        _leftLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 29, 1)];
        _leftLine.backgroundColor = [UIColor colorWithString:@"6d6d6d"];
        [self insertSubview:_leftLine atIndex:0];
    }
    return self;
}

-(void)layoutSubviews{
    CGPoint center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
    _circle.center = center;
    _bluetooth.center = center;
    
    CGRect frame = _topLine.frame;
    frame.origin.x = center.x - 0.5;
    frame.origin.y = CGRectGetMinY(_bluetooth.frame) - CGRectGetHeight(_topLine.frame);
    _topLine.frame = frame;
    
    frame = _leftLine.frame;
    frame.origin.x = CGRectGetMinX(_bluetooth.frame) - CGRectGetWidth(_leftLine.frame);
    frame.origin.y = center.y - 0.5;
    _leftLine.frame = frame;
    
    frame = _bottomLine.frame;
    frame.origin.x = CGRectGetMinX(_topLine.frame);
    frame.origin.y = CGRectGetMaxY(_bluetooth.frame);
    _bottomLine.frame = frame;
    
    frame = _rightLine.frame;
    frame.origin.x = CGRectGetMaxX(_bluetooth.frame);
    frame.origin.y = CGRectGetMinY(_leftLine.frame);
    _rightLine.frame = frame;
}

-(void)setItemsTheImage:(NSArray *)images highlightImages:(NSArray *)highlightImages{
    for (int i = 0 ; i < _items.count; i++) {
        UIButton *tmpButton = _items[i];
        [tmpButton setBackgroundImage:images[i] forState:UIControlStateNormal];
        [tmpButton setBackgroundImage:highlightImages[i] forState:UIControlStateSelected];
        [tmpButton setBackgroundImage:highlightImages[i] forState:UIControlStateHighlighted];
    }
}

-(void)setButtonPosition{
    CGFloat centerX = CGRectGetWidth(self.bounds) / 2;
    CGFloat centerY = CGRectGetHeight(self.bounds) / 2;
    NSArray *points = @[[NSValue valueWithCGPoint:CGPointMake(centerX, SPACING + BUTTON_SIZE / 2)],[NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.bounds) - SPACING - BUTTON_SIZE / 2 , centerY)],[NSValue valueWithCGPoint:CGPointMake(centerX, CGRectGetHeight(self.bounds)- SPACING - BUTTON_SIZE / 2)],[NSValue valueWithCGPoint:CGPointMake( BUTTON_SIZE / 2 + SPACING, centerY)]];
    for (int i = 0 ; i < _items.count; i++) {
        UIButton *tmpButton = _items[i];
        tmpButton.center = [points[i] CGPointValue];
        
    }
}

-(void)clickToButton:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(clickedPanelAtIndex:)]) {
        [self.delegate clickedPanelAtIndex:sender.tag];
    }
//    sender.userInteractionEnabled = NO;
//    sender.selected = YES;
//    CGRect frame = sender.frame;
//    [UIView animateWithDuration:.5 animations:^{
//        for (UIButton *tmpButton in _items) {
//            if (![tmpButton isEqual:sender]) {
//                tmpButton.alpha = 0;
//            }
//        }
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:.5 animations:^{
//            sender.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
//        } completion:^(BOOL finished) {
//            _background.hidden = YES;
//            _circle.hidden = YES;
//            _bluetooth.hidden = YES;
//            _topLine.hidden = YES;
//            _leftLine.hidden = YES;
//            _bottomLine.hidden = YES;
//            _rightLine.hidden = YES;
//            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//            scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(10.0, 10.0, 1.0)];
//            
//            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//            opacityAnimation.toValue = [NSNumber numberWithFloat:0.0f];
//            
//            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
//            animationGroup.animations = @[scaleAnimation,opacityAnimation];
//            animationGroup.delegate = self;
//            animationGroup.duration = .5;
//            animationGroup.repeatCount = 1;
//            [animationGroup setValue:[NSValue valueWithCGRect:frame] forKey:@"Identity"];
//            [animationGroup setValue:sender forKey:@"animtionWithObject"];
//            [sender.layer addAnimation:animationGroup forKey:@"group"];
//            
//        }];
//    }];
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        UIButton *currentButton = [anim valueForKey:@"animtionWithObject"];
         CGRect frame = [[anim valueForKey:@"Identity"] CGRectValue];
        if ([self.delegate respondsToSelector:@selector(clickedPanelAtIndex:)]) {
            [self.delegate clickedPanelAtIndex:currentButton.tag];
        }
        currentButton.userInteractionEnabled = YES;
        currentButton.frame = frame;
        currentButton.selected = NO;
        _background.hidden = NO;
        _circle.hidden = NO;
        _bluetooth.hidden = NO;
        _topLine.hidden = NO;
        _leftLine.hidden = NO;
        _bottomLine.hidden = NO;
        _rightLine.hidden = NO;
        for (UIButton *tmpButton in _items) {
            if (![tmpButton isEqual:currentButton]) {
                tmpButton.alpha = 1;
            }
        }
    }
}
-(void)startAnimationWithBackgroundAndCircle{
    CABasicAnimation *backgroundAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    backgroundAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    backgroundAnimation.duration = 17.0;
    backgroundAnimation.repeatCount = MAXFLOAT;
    [_background.layer addAnimation:backgroundAnimation forKey:@"backgroundRotation"];
    
    CABasicAnimation *circleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    circleAnimation.toValue = [NSNumber numberWithFloat:-M_PI * 2.0];
    circleAnimation.duration = 20.0;
    circleAnimation.repeatCount = MAXFLOAT;
    [_circle.layer addAnimation:circleAnimation forKey:@"circleRotation"];
}
-(void)stopAnimationWithBackgroundAndCircle{
    [_background.layer removeAllAnimations];
    [_circle.layer removeAllAnimations];
}

-(void)setBluetoothState:(BOOL)on{
    if (on) {
        _bluetooth.image = [UIImage imageNamed:@"home_img_bluetooth_on"];
    }else{
        _bluetooth.image = [UIImage imageNamed:@"home_img_bluetooth_off"];
    }
    
}
@end
