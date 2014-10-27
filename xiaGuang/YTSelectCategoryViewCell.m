//
//  YTSelectCategoryViewCell.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-22.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSelectCategoryViewCell.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@interface YTSelectCategoryViewCell(){
    UIImageView *_icon;
    UILabel *_title;
    UIImageView *_accessory;
    UIView *_background;
}
@end
@implementation YTSelectCategoryViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _icon = [[UIImageView alloc]init];
        _title = [[UILabel alloc]init];
        _accessory = [[UIImageView alloc]init];
        _background = [[UIView alloc]init];
        
        [self addSubview:_background];
        [self addSubview:_icon];
        [self addSubview:_title];
        [self addSubview:_accessory];
    
       
        
    }
    
    return self;
}

-(void)layoutSubviews{
    _icon.frame = CGRectMake(25, 22 - 7.5, 15, 15);
    _icon.image = self.category.smallImage;
    
    _title.frame = CGRectMake(CGRectGetMaxX(_icon.frame) + 10, CGRectGetMinY(_icon.frame), 100, 14);
    _title.text = self.category.text;
    _title.font = [UIFont systemFontOfSize:14];
    
    UIImage *arrow = [UIImage imageNamed:@"type_img_arrow2"];
    _accessory.frame = CGRectMake(CGRectGetMaxX(self.frame) - 15 - arrow.size.width, _icon.center.y - arrow.size.height / 2, arrow.size.width, arrow.size.height);
    _accessory.image = arrow;
    
    UIImageView *background = [[UIImageView alloc]initWithFrame:self.bounds];
    background.image = [UIImage imageNamed:@"type_img_leftlist_un"];
    self.backgroundView = background;
    
    if ([_title.text isEqualToString:@"全部分类"]) {
        _accessory.hidden = YES;
    }
    
    _background.frame = self.bounds;
    _background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"type_img_rightlist"]];
}
-(void)setIsSelect:(BOOL)isSelect{
    if (isSelect) {
        _title.textColor = [UIColor colorWithString:@"e95e37"];
        _background.hidden = NO;
    }else{
        _title.textColor = [UIColor colorWithString:@"404040"];
        _background.hidden = YES;
        
    }
    
}

@end
