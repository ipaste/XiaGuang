//
//  YTSwitchBlockView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-11.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSwitchBlockView.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#define HEIGHT 32
@interface YTSwitchBlockView(){
    CGFloat _textLenght;
    NSArray *_blocks;
    UIButton *_blockButton;
    UIScrollView * _scrollView;
    UIView *_verticalLine;
    CGFloat _scrollViewWidth;
    
    NSMutableArray *_blockButtons;
}
@end

@implementation YTSwitchBlockView
-(instancetype)initWithPosition:(CGPoint)position currentMajorArea:(id <YTMajorArea>)majorArea{
    CGFloat width = HEIGHT;
    _textLenght = [[[majorArea floor] block] blockName].length * 14;
    width += 10;
    width += 5;
    width += _textLenght ;
    CGFloat offsetX = (width - 75) / 14 * 5 ;
    self = [super initWithFrame:CGRectMake(position.x - offsetX, position.y, width, HEIGHT)];
    if (self) {
        _blockButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - _textLenght - 37, 0, _textLenght, HEIGHT)];
       [_blockButton setTitle:[[[majorArea floor] block] blockName] forState:UIControlStateNormal];
        [_blockButton addTarget:self action:@selector(switchBlock:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_blockButton];
        
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 0, HEIGHT)];
        [self addSubview:_scrollView];
        
        _verticalLine = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_blockButton.frame) - 10, 10, 1, 12)];
        _verticalLine.backgroundColor = [UIColor colorWithString:@"c8c8c8"];
        [self addSubview:_verticalLine];
        
        _blocks = [[[[majorArea floor] block] mall] blocks];
        _blockButtons = [NSMutableArray array];
        for (int i = 0 ; i < _blocks.count; i++) {
            id<YTBlock> block = _blocks[i];
            CGFloat width = [block blockName].length * 14;
            UIButton *blockButton = [[UIButton alloc]initWithFrame:CGRectMake(10 + i * width , 0,width , HEIGHT)];
            [blockButton addTarget:self action:@selector(clickBlockButton:) forControlEvents:UIControlEventTouchUpInside];
            blockButton.tag = i;
            [_blockButtons addObject:blockButton];
            [_scrollView addSubview:blockButton];
        }
    }
    return self;
}

-(void)redrawWithMajorArea:(id<YTMajorArea>)majorArea{
    
    CGFloat width = HEIGHT;
    _textLenght = [[[majorArea floor] block] blockName].length * 14;
    width += 10;
    width += 5;
    width += _textLenght ;
    CGFloat offsetX = (width - 75) / 14 * 5 ;
    CGPoint position = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
    self.frame = CGRectMake(position.x - offsetX, position.y, width, HEIGHT);
    
    [_blockButton removeFromSuperview];
    [_scrollView removeFromSuperview];
    [_verticalLine removeFromSuperview];
    
    
    _blockButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - _textLenght - 37, 0, _textLenght, HEIGHT)];
    [_blockButton setTitle:[[[majorArea floor] block] blockName] forState:UIControlStateNormal];
    
    [_blockButton addTarget:self action:@selector(switchBlock:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_blockButton];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 0, HEIGHT)];
    [self addSubview:_scrollView];
    
    _verticalLine = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_blockButton.frame) - 10, 10, 1, 12)];
    _verticalLine.backgroundColor = [UIColor colorWithString:@"c8c8c8"];
    [self addSubview:_verticalLine];
    
    _blocks = [[[[majorArea floor] block] mall] blocks];
    _blockButtons = [NSMutableArray array];

    for (int i = 0 ; i < _blocks.count; i++) {
        id<YTBlock> block = _blocks[i];
        CGFloat width = [block blockName].length * 14;
        UIButton *blockButton = [[UIButton alloc]initWithFrame:CGRectMake(10 + i * width , 0,width , HEIGHT)];
        [blockButton addTarget:self action:@selector(clickBlockButton:) forControlEvents:UIControlEventTouchUpInside];
        blockButton.tag = i;
        [_blockButtons addObject:blockButton];
        [_scrollView addSubview:blockButton];
    }

}

-(void)promptBlockChange:(id<YTBlock>)block{
    [_blockButton setTitle:[block blockName] forState:UIControlStateNormal];
}


-(void)layoutSubviews{
    [_blockButton setTitleColor:[UIColor colorWithString:@"202020"] forState:UIControlStateNormal];
    [_blockButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    
    CGFloat width = 0;
    UIColor *color = [UIColor colorWithString:@"202020"];
    for (int i = 0 ; i < _blocks.count; i++) {
        id<YTBlock> block = _blocks[i];
        UIButton *blockButton = _blockButtons[i];
        [blockButton setTitle:[block blockName] forState:UIControlStateNormal];
        
        if ([[block blockName] isEqualToString:_blockButton.titleLabel.text]) {
            color = [UIColor colorWithString:@"e95e37"];
        }
        [blockButton setTitleColor:color forState:UIControlStateNormal];
        [blockButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        
        if (i <= 3) {
           width += [block blockName].length * 14 + 10;
        }
    }
    _scrollViewWidth = width;
    
    _verticalLine.frame = CGRectMake(CGRectGetMinX(_blockButton.frame) - 10, 10, 1, 12);
    
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = HEIGHT / 2;
    self.layer.borderColor = [UIColor colorWithString:@"c8c8c8"].CGColor;
    self.layer.borderWidth = 1;
    self.layer.masksToBounds = YES;
    self.layer.anchorPoint = CGPointMake(1, 0.5);
}
-(void)toggleBlockView{
    [self switchBlock:_blockButton];
}
-(void)switchBlock:(UIButton *)sender{
    [UIView animateWithDuration:.2 animations:^{
        CGRect frame = CGRectZero;
        if (!_toggle) {
            _toggle = true;
            frame = self.frame;
            frame.size.width += _scrollViewWidth + 10;
            frame.origin.x -= _scrollViewWidth + 10;
            self.frame = frame;
            
            frame = _scrollView.frame;
            frame.size.width = _scrollViewWidth;
            _scrollView.frame = frame;
        }else{
            _toggle = false;
            frame = self.frame;
            frame.size.width -= _scrollViewWidth + 10;
            frame.origin.x += _scrollViewWidth + 10;
            self.frame = frame;
            
            frame = _scrollView.frame;
            frame.size.width = 0;
            _scrollView.frame = frame;
        }
        frame = _blockButton.frame;
        frame.origin.x = CGRectGetWidth(self.frame) - _textLenght - 37;
        _blockButton.frame = frame;
    
    } completion:^(BOOL finished) {
        
    }];
    
}
-(void)clickBlockButton:(UIButton *)sender{
    id<YTBlock> block = _blocks[sender.tag];
    [self switchBlock:_blockButton];
    if ([self.delegate respondsToSelector:@selector(switchBlock:)]) {
        [self.delegate switchBlock:block];
    }
}
@end
