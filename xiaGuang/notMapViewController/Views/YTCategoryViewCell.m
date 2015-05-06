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
        _subTitles = [NSMutableArray array];
        _subImage = [NSMutableArray array];
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 40, 40)];
        _label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_imageView.frame) + 10, CGRectGetMinY(_imageView.frame) + 5, 150, 16)];
        _line = [[UIView alloc]init];
        
        for (int i = 0 ; i < 5; i++) {
            UILabel *subLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_label.frame) + i % 5 * 33.5, CGRectGetMaxY(_label.frame), 24, 20)];
            [self addSubview:subLabel];
            subLabel.hidden = YES;
            [_subTitles addObject:subLabel];
            
            UIImage *image = [UIImage imageNamed:@"home3_img_dot"];
            UIImageView *subImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(subLabel.frame) +  3, 0, image.size.width, image.size.height)];
            subImageView.image = image;
            subImageView.center = CGPointMake(subImageView.center.x, subLabel.center.y);
            subImageView.hidden = YES;
            [self addSubview:subImageView];
            [_subImage addObject:subImageView];
        }
        
        [self addSubview:_imageView];
        [self addSubview:_label];
        
        
        UIImage *accessoryImage = [UIImage imageNamed:@"home_img_arrow"];
        UIImageView *accessoryImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - accessoryImage.size.width - 15, (60 - accessoryImage.size.height) / 2, accessoryImage.size.width ,  accessoryImage.size.height)];
        accessoryImageView.image = accessoryImage;
        
        [self addSubview:accessoryImageView];
        [self addSubview:_line];
        UIView *backgroundView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, CGRectGetWidth(self.frame), 60)];
        backgroundView.backgroundColor = [UIColor colorWithString:@"000000" alpha:0.06];
        
        self.selectedBackgroundView = backgroundView;
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
    NSMutableArray *subCategory = [NSMutableArray arrayWithArray:self.category.subText];
    [subCategory removeObjectAtIndex:0];
    for (int i = 0; i < _subTitles.count; i++) {
        UIImageView *subImageView = _subImage[i];
        UILabel *subLabel = _subTitles[i];
        if (i < subCategory.count) {
            subLabel.font = [UIFont systemFontOfSize:12];
            subLabel.textColor = [UIColor colorWithString:@"999999"];
            subLabel.text = subCategory[i];
            subLabel.hidden = NO;
            CGSize textSize = [subLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : subLabel.font} context:nil].size;
            CGRect frame = subLabel.frame;
            frame.size.width = textSize.width;
            subLabel.frame = frame;
        }else{
            subLabel.hidden = YES;
        }
        
        if (i < _subTitles.count - 1 && i < subCategory.count - 1) {
            subImageView.hidden = NO;
        }else if (i >= _subTitles.count){
            subImageView.hidden = YES;
        }
    }
}

-(void)dealloc{
    [_subTitles removeAllObjects];
    [_subImage removeAllObjects];
}
@end
