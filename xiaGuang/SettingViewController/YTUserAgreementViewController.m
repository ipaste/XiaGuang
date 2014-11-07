//
//  YTUserAgreementViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-28.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTUserAgreementViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@interface YTUserAgreementViewController (){
    UIScrollView *_scrollerView;
    UILabel *_titleLabel;
}
@end

@implementation YTUserAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"用户协议";
    _scrollerView  = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    _scrollerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];
    [self.view addSubview:_scrollerView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _titleLabel = [[UILabel alloc]init];
    [_scrollerView addSubview:_titleLabel];
}

-(void)viewWillLayoutSubviews{
    NSString *userAgreementPath = [[NSBundle mainBundle]pathForResource:@"userAgreement" ofType:@"txt"];
    NSString *text = [NSString stringWithContentsOfFile:userAgreementPath encoding:NSUTF8StringEncoding error:nil];
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.frame) - 30, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],NSForegroundColorAttributeName : [UIColor colorWithString:@"202020"]} context:nil].size;
    _scrollerView.contentSize = CGSizeMake(CGRectGetWidth(_scrollerView.frame), textSize.height + 100);
    
    
    _titleLabel.frame = CGRectMake(15, 25, 290, textSize.height);
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.text = text;
    _titleLabel.textColor = [UIColor colorWithString:@"202020"];
}

-(void)dealloc{
    NSLog(@"userAgreementDealloc");
}

@end
