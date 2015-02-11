//
//  YTPreferentialCell.m
//  虾逛
//
//  Created by YunTop on 15/2/5.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTPreferentialCell.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"

#define ICON_WIDTH_HEIGHT 59
@implementation YTPreferentialCell
{
    UIImageView *_imageView;
    UILabel *_textLabel;
    UILabel *_originalPriceLabel;
    UILabel *_favorablePriceLabel;
    UIView *_lineView;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(ICON_WIDTH_HEIGHT, ICON_WIDTH_HEIGHT);
        frame.origin = CGPointMake(15, 18);
        _imageView = [[UIImageView alloc]initWithFrame:frame];
        _imageView.image = [UIImage imageNamed:@"imgshop_default"];
        
        frame.size = CGSizeMake(CGRectGetWidth(self.frame) - CGRectGetMaxX(_imageView.frame) - 10, 15);
        frame.origin = CGPointMake(CGRectGetMaxX(_imageView.frame) + 10, 26);
        _textLabel = [[UILabel alloc]initWithFrame:frame];
        
        
        frame.size = CGSizeMake(100, 18);
        frame.origin = CGPointMake(CGRectGetMinX(_textLabel.frame), CGRectGetMaxY(_textLabel.frame) + 16);
        _favorablePriceLabel = [[UILabel alloc]initWithFrame:frame];
        
        frame.size = CGSizeMake(100, 18);
        frame.origin = CGPointMake(CGRectGetMaxX(_favorablePriceLabel.frame) + 12, CGRectGetMinY(_favorablePriceLabel.frame));
        _originalPriceLabel = [[UILabel alloc]initWithFrame:frame];
        
        frame.size = CGSizeMake(CGRectGetWidth(self.frame) - 20, 0.5);
        frame.origin = CGPointMake(10, CGRectGetMaxY(_imageView.frame) + 18);
        _lineView = [[UIView alloc]initWithFrame:frame];
        
        [self addSubview:_imageView];
        [self addSubview:_textLabel];
        [self addSubview:_originalPriceLabel];
        [self addSubview:_favorablePriceLabel];
        [self addSubview:_lineView];
    }
    return self;
}

-(void)layoutSubviews{
    _imageView.layer.cornerRadius = CGRectGetWidth(_imageView.frame) / 2;
    _imageView.layer.masksToBounds = true;
    
    _textLabel.textColor = [UIColor colorWithString:@"333333"];
    _textLabel.font = [UIFont systemFontOfSize:15];

    _originalPriceLabel.textColor = [UIColor colorWithString:@"999999"];
    _originalPriceLabel.font = [UIFont systemFontOfSize:12];
    
    _favorablePriceLabel.textColor = [UIColor colorWithString:@"e95e37"];
    _favorablePriceLabel.font = [UIFont systemFontOfSize:13];
    
    _lineView.backgroundColor = [UIColor colorWithString:@"b2b2b2"];
}


-(void)setPreferential:(YTPreferential *)preferential{
    [preferential getThumbnailWithCallBack:^(UIImage *result, NSError *error) {
        if (result) {
            _imageView.image = result;
        }else{
            _imageView.image = [UIImage imageNamed:@"imgshop_default"];
        }
    }];
    
    if (preferential != nil) {
        _textLabel.text = preferential.preferentialInfo;
        _originalPriceLabel.text = preferential.originalPrice.stringValue;
        _favorablePriceLabel.text = [preferential.favorablePrice.stringValue  stringByAppendingString:@"元"];
    }else{
        _imageView.image = [UIImage imageNamed:@"imgshop_default"];
        _textLabel.text = @"走过路过不要错过";
        _originalPriceLabel.text = @"100";
        _favorablePriceLabel.text = @"88元";
    }
    
    
    CGSize textSize = [_favorablePriceLabel.text boundingRectWithSize:CGSizeMake(100, 18) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_favorablePriceLabel.font} context:nil].size;
    CGRect frame = _favorablePriceLabel.frame;
    frame.size.width = textSize.width;
    _favorablePriceLabel.frame = frame;
    
    
    textSize = [_originalPriceLabel.text boundingRectWithSize:CGSizeMake(100, 18) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_originalPriceLabel.font} context:nil].size;
    frame.size.width = textSize.width;
    frame.origin.x = CGRectGetMaxX(_favorablePriceLabel.frame) + 12;
    _originalPriceLabel.frame = frame;

    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithAttributedString:_originalPriceLabel.attributedText];
    NSRange titleRange = {0,_originalPriceLabel.text.length};
    
    [string addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlinePatternSolid|NSUnderlineStyleSingle] range:titleRange];
    
    _originalPriceLabel.attributedText = string;
    
}

@end


