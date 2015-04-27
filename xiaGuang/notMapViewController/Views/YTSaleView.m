//
//  YTSaleView.m
//  虾逛
//
//  Created by YunTop on 15/4/23.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTSaleView.h"

#define DEFAULT_TOP_SEPACING 13.5
#define DEFAULT_FONT_SIZE 13
#define SOLE_IMAGE [UIImage imageNamed:@"flag_du"]
#define OTHER_IMAGE [UIImage imageNamed:@"flag_tuan"]
@interface YTSaleView(){
    UIImage *_defaultImage;
    UIImageView *_merchantImageView;
    UIImageView *_markImageView;
    UILabel *_merchantLabel;
    UILabel *_saleLabel;
    UIView *_lineView;
}

@end

@implementation YTSaleView

- (instancetype)init{
   return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _defaultImage = [UIImage imageNamed:@"noagio_img"];
        _merchantImageView = [[UIImageView alloc]initWithImage:_defaultImage];
        _merchantImageView.layer.cornerRadius = _defaultImage.size.width / 2;
        _merchantImageView.layer.masksToBounds = true;
        [self addSubview:_merchantImageView];
        
        _merchantLabel = [[UILabel alloc]init];
        _merchantLabel.font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
        _merchantLabel.text = @"敬请期待";
        _merchantLabel.textAlignment = NSTextAlignmentCenter;
        _merchantLabel.userInteractionEnabled = false;
        _merchantLabel.textColor = [UIColor colorWithString:@"333333"];
        [self addSubview:_merchantLabel];
        
        _saleLabel = [[UILabel alloc]init];
        _saleLabel.font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
        _saleLabel.text = @"暂无优惠";
        _saleLabel.textAlignment = NSTextAlignmentCenter;
        _saleLabel.userInteractionEnabled = false;
        _saleLabel.textColor = [UIColor colorWithString:@"e95e37"];
        [self addSubview:_saleLabel];
       
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = [UIColor colorWithString:@"b2b2b2"];
        [self addSubview:_lineView];
        
        _markImageView = [[UIImageView alloc]init];
        [self addSubview:_markImageView];
        
    }
    return self;
}


- (void)layoutSubviews{
    CGRect frame = _merchantImageView.frame;
    frame.origin.x = 0;
    frame.origin.y = DEFAULT_TOP_SEPACING;
    frame.size.width = _defaultImage.size.width;
    frame.size.height = _defaultImage.size.height;
    _merchantImageView.frame = frame;
    _merchantImageView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, _merchantImageView.center.y);
    
    frame = _merchantLabel.frame;
    frame.origin.x = 12;
    frame.origin.y = CGRectGetMaxY(_merchantImageView.frame) + 10;
    frame.size.width = CGRectGetWidth(self.frame) - frame.origin.x * 2;
    frame.size.height = DEFAULT_FONT_SIZE;
    _merchantLabel.frame = frame;
    
    frame = _saleLabel.frame;
    frame.origin.x = 12;
    frame.origin.y = CGRectGetMaxY(_merchantLabel.frame) + 10;
    frame.size.width = CGRectGetWidth(_merchantLabel.frame);
    frame.size.height = DEFAULT_FONT_SIZE;
    _saleLabel.frame = frame;
    
    frame = _lineView.frame;
    frame.origin.x = 0.5;
    frame.origin.y = DEFAULT_TOP_SEPACING;
    frame.size.width = 0.5;
    frame.size.height = CGRectGetHeight(self.frame) - DEFAULT_TOP_SEPACING * 2;
    _lineView.frame = frame;
    
    frame = _markImageView.frame;
    frame.origin.x = CGRectGetWidth(self.frame) - 30;
    frame.origin.y = 0;
    frame.size.width = 30;
    frame.size.height = 30;
    _markImageView.frame = frame;
}


- (void)setSaleViewWithMerchantImage:(UIImage *)image
                        merchantName:(NSString *)merchantName
                            saleInfo:(NSString *)saleInfo
                              isSole:(BOOL)isSole
{
    if (image) {
        _merchantImageView.image = image;

    }
    
    if (merchantName) {
        _merchantLabel.text = merchantName;
    }
    
    if (saleInfo) {
        _saleLabel.text = saleInfo;
    }
    
    if (isSole) {
        _markImageView.image = SOLE_IMAGE;
    }else{
        _markImageView.image = OTHER_IMAGE;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([_delegate respondsToSelector:@selector(touchBeganWithSaleView:)]) {
        [_delegate touchBeganWithSaleView:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([_delegate respondsToSelector:@selector(touchEndWithSaleView:)]) {
        [_delegate touchEndWithSaleView:self];
    }
}
@end
