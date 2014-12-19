//
//  YTMallCell.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-11.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMallCell.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"

@interface YTMallCell(){
    UIImageView *_mallBackgroundView;
    UIImageView *_titleImageView;
}
@end

@implementation YTMallCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _mallBackgroundView = [[UIImageView alloc]init];
        _titleImageView = [[UIImageView alloc]init];
        [self addSubview:_mallBackgroundView];
        [self addSubview:_titleImageView];
    }
    
    return self;
}

-(void)layoutSubviews{
    _mallBackgroundView.layer.cornerRadius = 10;
    _mallBackgroundView.layer.masksToBounds = true;
    self.backgroundColor = [UIColor clearColor];
}

-(void)setMall:(id<YTMall>)mall{
    [mall getPosterTitleImageAndBackground:^(UIImage *titleImage, UIImage *background, NSError *error) {
        _mallBackgroundView.image = background;
        _mallBackgroundView.frame = CGRectMake(10, 10, background.size.width / 2, background.size.height / 2);
        _titleImageView.image = titleImage;
        _titleImageView.frame = CGRectMake(20, CGRectGetHeight(self.frame) - titleImage.size.height / 2, titleImage.size.width / 2, titleImage.size.height / 2);
    }];
    _mall = mall;
}


@end
