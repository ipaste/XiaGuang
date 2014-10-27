//
//  YTMoreCategoryViewCell.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-18.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMoreCategoryViewCell.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@interface YTMoreCategoryViewCell(){
    NSMutableArray *_subCategory;
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UIView *_lineView;
    YTCategory *_category;
}
@end
@implementation YTMoreCategoryViewCell

-(id)initWithCategory:(YTCategory *)category reuseIdentifier:(NSString *)reuseIdentifier{
    _category = category;
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(25, 20, 15, 15)];
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_imageView.frame) + 5, CGRectGetMinY(_imageView.frame),  32, 16)];
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_imageView.frame), CGRectGetMaxY(_titleLabel.frame) + 2, CGRectGetWidth(self.frame) - CGRectGetMinX(_imageView.frame), 0.5)];
        _subCategory = [NSMutableArray array];
        for (int i = 0 ; i < _category.subText.count; i++) {
            UIButton *subCategoryButton = [[UIButton alloc]initWithFrame:CGRectMake(25  + i % 3 * 95 , (CGRectGetMaxY(_lineView.frame) + 10)  + i / 3 * 40, 85, 30)];
            subCategoryButton.tag  = i;
            subCategoryButton.hidden = YES;
            [subCategoryButton addTarget:self action:@selector(jumpToCategory:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:subCategoryButton];
            [_subCategory addObject:subCategoryButton];
        }
        
        [self addSubview:_imageView];
        [self addSubview:_titleLabel];
        [self addSubview:_lineView];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)layoutSubviews{
    _imageView.image = _category.smallImage;
    
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    _titleLabel.textColor = _category.titleColor;
    _titleLabel.text = _category.text;
    
    _lineView.backgroundColor = _category.tintColor;
    
    for (int i = 0 ; i < _subCategory.count; i++) {
        UIButton *subCategoryButton = _subCategory[i];
        subCategoryButton.hidden = NO;
        [subCategoryButton setTitle:_category.subText[i] forState:UIControlStateNormal];
        [subCategoryButton setTitleColor:[UIColor colorWithString:@"606060"] forState:UIControlStateNormal];
        [subCategoryButton setBackgroundImage:[UIImage imageNamed:@"search_btn_un"] forState:UIControlStateNormal];
        [subCategoryButton setBackgroundImage:[UIImage imageNamed:@"search_btn_pr"] forState:UIControlStateHighlighted];
        [subCategoryButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    }
}

-(void)jumpToCategory:(UIButton *)sender{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"YTMoreCategoryTitle" object:nil userInfo:@{@"subTitle":sender.titleLabel.text,@"title":_category.text}];
}
@end
