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
        _mallBackgroundView.frame = CGRectMake(10, 10, 300, 120);
        _titleImageView = [[UIImageView alloc]init];
        _titleImageView.frame = CGRectMake(20, 20, 150, 30);
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
        NSLog(@"fetch something");
        
        NSLog(@"background size: %f,%f",titleImage.size.width,titleImage.size.height);
        
        
        _mallBackgroundView.image = background;
        _titleImageView.image = titleImage;
        
    }];
    _mall = mall;
}


@end
