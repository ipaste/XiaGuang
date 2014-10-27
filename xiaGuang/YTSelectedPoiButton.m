//
//  YTSelectedPoiButton.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-16.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSelectedPoiButton.h"
@interface YTSelectedPoiButton(){
    UIImageView *_cancelImageView;
    UIImageView *_selectedImageView;
}
@end

@implementation YTSelectedPoiButton
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _selectedImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:_selectedImageView];
        _cancelImageView = [[UIImageView alloc]init];
        [self addSubview:_cancelImageView];
        [self addTarget:self action:@selector(clickToButton:) forControlEvents:UIControlEventTouchUpInside];
        
        self.hidden = YES;
    }
    return self;
}

-(void)layoutSubviews{
    UIImage *image = [UIImage imageNamed:@"nav_img_close"];
    _cancelImageView.image = image;
    _cancelImageView.frame = CGRectMake(CGRectGetWidth(self.frame) / 2 + image.size.width / 2, CGRectGetHeight(self.frame) / 2 + image.size.height / 2, image.size.width, image.size.height);
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2;
    self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
}

-(void)setPoiImage:(UIImage *)image{
    self.hidden = NO;
    _selectedImageView.image = image;
}

-(void)clickToButton:(UIButton *)sender{
    self.hidden = YES;
    [self.delegate selectedPoiButtonClicked];
}
@end
