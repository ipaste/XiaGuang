//
//  YTChoosRegionView.m
//  虾逛
//
//  Created by YunTop on 15/4/17.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTChoosRegionView.h"
#define SPACIING 12.5
@interface YTChoosRegionView(){
    NSMutableArray *_regions;
    UIButton *_selectButton;
}
@end

@implementation YTChoosRegionView
- (instancetype)initWithFrame:(CGRect)frame
                         city:(YTCity *)city{
    self = [super initWithFrame:frame];
    if (self) {
        _regions = [NSMutableArray arrayWithArray:city.regions];
        [_regions insertObject:@"全城" atIndex:0];
        double oneButtonWidth = (CGRectGetWidth(frame) - 50) / 3;
        double oneButtonHeight = 40;
        CGFloat height = 0;
        for (NSInteger index = 0; index < _regions.count; index++) {
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(SPACIING + ((oneButtonWidth + SPACIING) * (index % 3)), 20 + (index / 3 * (SPACIING + oneButtonHeight)), oneButtonWidth, oneButtonHeight)];
            button.tag = index;
            id object = _regions[index];
            if ([object isMemberOfClass:[YTRegion class]]) {
                [button setTitle:[(YTRegion *)object name] forState:UIControlStateNormal];
            }else{
                [button setTitle:object forState:UIControlStateNormal];
                button.selected = true;
                _selectButton = button;
            }
            [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
            
            [button setTitleColor:[UIColor colorWithString:@"666666"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithString:@"ffffff"] forState:UIControlStateHighlighted];
            [button setTitleColor:[UIColor colorWithString:@"ffffff"] forState:UIControlStateSelected];
            
            [button setBackgroundImage:[UIImage imageNamed:@"btn_nomal"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"btn_focus"] forState:UIControlStateHighlighted];
            [button setBackgroundImage:[UIImage imageNamed:@"btn_focus"] forState:UIControlStateSelected];
            
            [button addTarget:self action:@selector(regionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            
            height = CGRectGetMaxY(button.frame);
        }
        
        CGRect frame = self.frame;
        frame.size.height = height + 20;
        self.frame = frame;
        self.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    }
    return self;
}

- (void)regionButtonClicked:(UIButton *)sender{
    _selectButton.selected = false;
    _selectButton = sender;
    _selectButton.selected = true;
    YTRegion *region = nil;
    if (sender.tag != 0) {
        region = _regions[sender.tag];
    }
    if ([_delegate respondsToSelector:@selector(selectRegion:)]){
        [_delegate selectRegion:region];
    }
    [self hide];
}

- (void)show{
    self.hidden = false;
}

- (void)hide{
    if ([_delegate respondsToSelector:@selector(hideChoosRegionView)]){
        [_delegate hideChoosRegionView];
    }
    self.hidden = true;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self hide];
}
@end
