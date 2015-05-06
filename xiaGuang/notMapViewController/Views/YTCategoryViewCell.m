//
//  YTClassificationViewCell.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTCategoryViewCell.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@interface YTCategoryViewCell(){
    UIImageView *_imageView;
    UILabel *_label;
    UIView *_line;
    NSMutableArray *_subTitles;
    NSMutableArray *_subImage;
}
@end
@implementation YTCategoryViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _subImage = [NSMutableArray array];
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 40, 40)];
        _label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_imageView.frame) + 10, 0, 150, 60)];
        _line = [[UIView alloc]init];
        
        [self addSubview:_imageView];
        [self addSubview:_label];
        
        
        UIImage *accessoryImage = [UIImage imageNamed:@"home_img_arrow"];
        UIImageView *accessoryImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - accessoryImage.size.width - 15, (60 - accessoryImage.size.height) / 2, accessoryImage.size.width ,  accessoryImage.size.height)];
        accessoryImageView.image = accessoryImage;
        
        [self addSubview:accessoryImageView];
        [self addSubview:_line];

        self.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
        
    }
    return self;
}

-(void)layoutSubviews{
    _imageView.layer.cornerRadius = 3.0;
    _imageView.image = self.category.image;
    
    _line.frame = CGRectMake(15, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame) - 30, 0.5);
    _line.backgroundColor = [UIColor colorWithString:@"b2b2b2"];
    
    _label.text = self.category.text;
    _label.textColor = [UIColor colorWithString:@"333333"];
    _label.font = [UIFont systemFontOfSize:16];

}

-(void)dealloc{
    [_subTitles removeAllObjects];
    [_subImage removeAllObjects];
}
@end
