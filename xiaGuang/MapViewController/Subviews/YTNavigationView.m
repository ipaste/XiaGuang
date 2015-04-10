//
//  YTNavigationView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-4.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTNavigationView.h"
#import "YTNavigationInstruction.h"
#import "POP.h"
#import "YTMessageBox.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#define TEXTCOLOR_AND_ARROWCOLOR [UIColor colorWithRed:139/255.0f green:139/255.0f blue:139/255.0f alpha:1.0]


@interface YTNavigationView ()<YTMessageBoxDelegate>{
    UILabel *_label;
    UILabel *_subLabel;
    UIButton *_stopNavigation;
    UIButton *_switchButton;
    UIImageView *_icon;
    YTMessageBox *_messageBox;
    id <YTPoiSource> _poiSource;
    BOOL _approachMessageShown;
}
@end

@implementation YTNavigationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc]initWithFrame:CGRectMake(15, 21, 200, 14)];
        _subLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_label.frame) + 22, CGRectGetMaxY(_label.frame) + 8, 200, 16)];
        
        _icon = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_label.frame), CGRectGetMaxY(_label.frame) + 8, 16, 16)];
        
        
        _stopNavigation = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(frame) - 69, 14.5, 51, 51)];
        
        _switchButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(_stopNavigation.frame) - CGRectGetWidth(_stopNavigation.frame) - 18, CGRectGetMinY(_stopNavigation.frame), CGRectGetWidth(_stopNavigation.frame), CGRectGetHeight(_stopNavigation.frame))];
        _messageBox = [[YTMessageBox alloc]initWithTitle:@"导航进行中..." Message:@"正在导航中，确定取消吗？"];
        _messageBox.delegate = self;
        [self addSubview:_icon];
        [self addSubview:_switchButton];
        [self addSubview:_stopNavigation];
        [self addSubview:_label];
        [self addSubview:_subLabel];
        _isCancelling = NO;
    }
    return self;
}

-(void)layoutSubviews{
    
    _label.font = [UIFont systemFontOfSize:14];
    _label.textColor = [UIColor colorWithString:@"f3b64b"];
    _label.text = [NSString stringWithFormat:@"终点:%@",_poiSource.name];
    
    
    _subLabel.font = [UIFont systemFontOfSize:16];
    _subLabel.textColor = [UIColor whiteColor];
    
    
    [_stopNavigation setTitle:@"结束" forState:UIControlStateNormal];
//    [_stopNavigation setBackgroundColor:[UIColor colorWithString:@"464646"]];
//    _stopNavigation.layer.cornerRadius = CGRectGetHeight(_stopNavigation.frame) / 2;
//    _stopNavigation.layer.borderWidth = 5;
    [_stopNavigation setBackgroundImage:[UIImage imageNamed:@"btn_gray"] forState:UIControlStateNormal];
    [_stopNavigation addTarget:self action:@selector(clickStopNavigationButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_switchButton setTitle:@"切换" forState:UIControlStateNormal];
//    [_switchButton setBackgroundColor:[UIColor colorWithString:@"0084ff"]];
//    _switchButton.layer.borderWidth = _stopNavigation.layer.borderWidth;
//    _switchButton.layer.cornerRadius = (CGRectGetHeight(self.frame) - 8) / 2;
    [_switchButton setBackgroundImage:[UIImage imageNamed:@"btn_orange"] forState:UIControlStateNormal];
    [_switchButton addTarget:self action:@selector(jumToBeacon:) forControlEvents:UIControlEventTouchUpInside];
    
    self.backgroundColor = [UIColor colorWithString:@"000000" alpha:0.6];
    
}

-(void)setIsShowSwitchButton:(BOOL)isShowSwitchButton{
    _switchButton.hidden = !isShowSwitchButton;
    
    _isShowSwitchButton = isShowSwitchButton;
    if (!_switchButton.hidden) {
        [self showSwitchAnimation];
    }
}

-(void)startNavigationAndSetDestination:(id <YTPoiSource>)source{
    
    _poiSource = source;
    _isNavigating = YES;
    [self setNeedsLayout];
}

-(void)clickStopNavigationButton:(UIButton *)sender{
    [_messageBox show];
}

-(void)jumToBeacon:(UIButton *)sender{
    [self.delegate jumToUserFloor];
    self.isShowSwitchButton = false;
}


-(void)updateInstruction{
   
    YTNavigationInstruction *instruction = [self.plan getInstruction];
    
    NSString *target = [[[[self.plan.targetPoiSource majorArea] floor] floorName] componentsSeparatedByString:@"F"][0];
    NSString *current = [[[[self.plan.userMinorArea majorArea] floor] floorName]componentsSeparatedByString:@"F"][0];
    if ([target integerValue] > [current integerValue]) {
        
        _icon.image = [UIImage imageNamed:@"nav_img_tip_up"];
        
    }else if ([target integerValue] < [current integerValue]){
        
        _icon.image = [UIImage imageNamed:@"nav_img_tip_down"];
        
    }else{
        
        _icon.image = [UIImage imageNamed:@"nav_img_tip_end"];
    }
    
    if (instruction.leftInstruction != nil) {
        _label.text = [NSString stringWithFormat:@"%@,%@",instruction.leftInstruction,instruction.rightInstruction];
    }else{
        _label.text = instruction.rightInstruction;
    }
    
    
    _subLabel.text = instruction.mainInstruction;
    if (instruction.type == YTNavigationInstructionApproachingDestination && !_approachMessageShown) {
         YTMessageBox *tmpMessage = [[YTMessageBox alloc]initWithTitle:@"虾逛提示" Message:@"您已处于目的地附近，导航结束"];
        tmpMessage.delegate = self;
        [tmpMessage show];
        _approachMessageShown = YES;
    }
}

-(void)showSwitchAnimation{
    [_switchButton.layer removeAllAnimations];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.toValue = [NSNumber numberWithFloat:0];
    animation.fromValue = [NSNumber numberWithFloat:1];
    animation.duration = 1;
    animation.repeatCount = 2;
    animation.removedOnCompletion = false;
    animation.delegate = self;
    animation.fillMode = kCAFillModeForwards;
    [_switchButton.layer addAnimation:animation forKey:@"animation"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    _switchButton.hidden = false;
}

-(void)clickToButtonAtTag:(NSInteger)tag{
    if (tag == 1) {        
        [self stopNavigationMode];
    }
}


-(void)stopNavigationMode{
    _isCancelling = YES;
    [self.delegate stopNavigationMode];
    _isCancelling = NO;
    _isNavigating = NO;
    _approachMessageShown = NO;
}
@end
