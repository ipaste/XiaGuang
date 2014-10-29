//
//  YTDetailsView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-15.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTDetailsView.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import <POP.h>
#define TEXTCOLOR_AND_ARROWCOLOR [UIColor colorWithRed:139/255.0f green:139/255.0f blue:139/255.0f alpha:1.0]
@implementation YTDetailsView{
    UILabel *_label;
    UIButton *_startNavigationButton;
    UIImageView *_merchantLogo;
    id<YTMerchantLocation> _merchantLocation;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc]initWithFrame:CGRectMake(70, 5, 200, 30)];
        _startNavigationButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(frame) - CGRectGetHeight(frame) - 15, 4, frame.size.height + 10, frame.size.height - 8)];
        _merchantLogo = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, frame.size.height - 10, frame.size.height - 10)];

        
        [self addSubview:_merchantLogo];
        [self addSubview:_startNavigationButton];
        [self addSubview:_label];
    }
    return self;
}

-(void)layoutSubviews{

    _label.font = [UIFont systemFontOfSize:18];
    _label.textColor = [UIColor whiteColor];
    
    
    _merchantLogo.layer.cornerRadius = CGRectGetWidth(_merchantLogo.frame) / 2;
    _merchantLogo.layer.masksToBounds = YES;
    
    [_startNavigationButton setTitle:@"导航" forState:UIControlStateNormal];
    [_startNavigationButton setBackgroundColor:[UIColor colorWithString:@"0084ff"]];
    _startNavigationButton.layer.cornerRadius = (CGRectGetHeight(self.frame) - 8) / 2;
    [_startNavigationButton addTarget:self action:@selector(clickStartNavigationButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setClipsToBounds:YES];
    self.backgroundColor = [UIColor blackColor];
    self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2;
    self.layer.masksToBounds = YES;
}

-(void)setMerchantInfo:(id<YTMerchantLocation>)merchantLocation{
    _label.text = [merchantLocation merchantLocationName];
    _merchantLogo.image = nil;
    [merchantLocation getCloudThumbNailWithCallBack:^(UIImage *result, NSError *error) {
         _merchantLogo.image = result;
    }];
    [merchantLocation getCloudMerchantTypeWithCallBack:^(NSArray *result, NSError *error) {
        [self setType:result];
    }];
    _merchantLocation = merchantLocation;
}


-(void)setCommonPoi:(id<YTPoiSource>)poi{
    _label.text = @"厕所";
    _merchantLogo.image = [UIImage imageNamed:@"nav_ico_9"];
}

-(void)setPoiSource:(id<YTPoiSource>)source{
    
}

-(void)clickStartNavigationButton:(UIButton *)sender{
    [self.delegate startNavigatingToMerchantLocation:_merchantLocation];
}


-(void)setType:(NSArray *)types{
    for (UIView *view in self.subviews) {
        if (view.tag == 1) {
            [view removeFromSuperview];
        }
    }

    UIImageView *beforeImageView = nil;
    for (int i = 0 ; i < types.count; i++) {
        NSString *type = types[i];
        CGFloat x = 0;
        CGFloat height = 42;
        UIImage *image = [UIImage imageNamed:@"nav_img_label_2"];
        if (type.length > 2) {
            height = 60;
            image = [UIImage imageNamed:@"nav_img_label_4"];
        }
        
        if (beforeImageView == nil) {
            x = CGRectGetMinX(_label.frame) + i * height;
        }else{
            x = CGRectGetMaxX(beforeImageView.frame) + 5;
        }
        
        UIImageView *categoryImageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(_label.frame), height, 16)];
        categoryImageView.tag = 1;
        categoryImageView.image = image;
        [self addSubview:categoryImageView];

        UILabel *categoryLabel = [[UILabel alloc]initWithFrame:categoryImageView.bounds];
        categoryLabel.text = type;
        categoryLabel.font = [UIFont systemFontOfSize:10];
        categoryLabel.textAlignment = 1;
        categoryLabel.textColor = [UIColor colorWithString:@"969696"];
        [categoryImageView addSubview:categoryLabel];
        beforeImageView = categoryImageView;
    }
}


@end
