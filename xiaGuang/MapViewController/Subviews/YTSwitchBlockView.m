//
//  YTSwitchBlockView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-11.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSwitchBlockView.h"
#import "YTBlockView.h"
#define WIDTH_AND_HEIGHT 41
#define BUTTON_PADDING 4
@interface YTSwitchBlockView()<YTBlockViewDelegate>{
    id<YTMajorArea> _majorArea;
    UIButton *_blockButton;
    UIImageView *_backgroundView;
    YTBlockView *_blockView;
    id<YTBlock> _block;
}
@end

@implementation YTSwitchBlockView

-(instancetype)initWithPosition:(CGPoint)position currentMajorArea:(id <YTMajorArea>)majorArea{
    self = [super initWithFrame:CGRectMake(position.x,position.y, WIDTH_AND_HEIGHT, WIDTH_AND_HEIGHT)];
    if (self) {
        _majorArea = majorArea;
        _block = [[majorArea floor] block];
        
        _backgroundView = [[UIImageView alloc]initWithFrame:self.bounds];
        _backgroundView.image = [UIImage imageNamed:@"btbg_blockOn"];
        [self addSubview:_backgroundView];
        _blockButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH_AND_HEIGHT, WIDTH_AND_HEIGHT)];
        _blockView = [[YTBlockView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_blockButton.frame), CGRectGetMinY(_blockButton.frame), WIDTH_AND_HEIGHT,WIDTH_AND_HEIGHT) andItem:[[[[_majorArea floor]block] mall] blocks]];
        _blockView.alpha = 0;
        [_blockButton setTitle:[[[_majorArea floor]block] blockName] forState:UIControlStateNormal];
        _blockView.blockDelegate = self;
        _blockView.curBlock = [[_majorArea floor] block];
        [self addSubview:_blockView];
        [self addSubview:_blockButton];
        
        [_blockButton setBackgroundImage:[UIImage imageNamed:@"btbg_block"] forState:UIControlStateNormal];
    }
    return self;
}

-(void)redrawWithMajorArea:(id<YTMajorArea>)majorArea{
    
    _majorArea = majorArea;
    
    _block = [[majorArea floor] block];
    
    //[_floorButton removeFromSuperview];
    [_blockView removeFromSuperview];
    
    //_floorButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH_AND_HEIGHT, WIDTH_AND_HEIGHT)];
    
    _blockView = [[YTBlockView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_blockButton.frame), CGRectGetMinY(_blockButton.frame) + 5, WIDTH_AND_HEIGHT,WIDTH_AND_HEIGHT) andItem:[[[[_majorArea floor]block] mall] blocks]];
    _blockView.alpha = 0;
    [_blockButton setTitle:[[[_majorArea floor]block] blockName] forState:UIControlStateNormal];
    _blockView.blockDelegate = self;
    _blockView.curBlock = [[_majorArea floor] block];
    [self addSubview:_blockView];
}

-(void)layoutSubviews{
    [_blockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_blockButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [_blockButton addTarget:self action:@selector(toggleBlockControl:) forControlEvents:UIControlEventTouchDown];
    
    _backgroundView.frame = self.bounds;
    // self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    self.layer.cornerRadius = WIDTH_AND_HEIGHT / 2;
    self.layer.masksToBounds = YES;
}

-(void)toggleBlockView{
    
    [self toggleBlockControl:_blockButton];
}

-(void)toggleBlockControl:(UIButton *)sender{
    if (self.toggle) {
        self.toggle = NO;
        _blockButton.alpha = 1;
        _blockView.alpha = 0;
        [UIView animateWithDuration:.2 animations:^{
            CGRect frame = self.frame;
            frame.size.height = WIDTH_AND_HEIGHT;
            self.frame = frame;
        }];
    }else{
        self.toggle = YES;
        _blockButton.alpha = 0;
        _blockView.alpha = 1;
        [UIView animateWithDuration:.2 animations:^{
            NSArray *blockItem = [[[[_majorArea floor] block]mall] blocks];
            CGRect frame = self.frame;
            if (blockItem.count < 3) {
                frame.size.height = blockItem.count * WIDTH_AND_HEIGHT;
            }else{
                frame.size.height = 3.3 * WIDTH_AND_HEIGHT;
            }
            self.frame = frame;
            
        }];
    }
}

-(void)blockView:(YTBlockView *)blockView clickButtonAtBlock:(id<YTBlock>)block{
    [self toggleBlockControl:_blockButton];
    [self promptBlockChange:block];
    [self.delegate switchBlock:block];
}

-(void)promptBlockChange:(id<YTBlock>)block{
    
    [_blockButton  setTitle:[block blockName] forState:UIControlStateNormal];
    _blockView.curBlock = block;
}


@end
