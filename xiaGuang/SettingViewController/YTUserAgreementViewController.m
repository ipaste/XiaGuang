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
    _scrollerView  = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    _scrollerView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    [self.view addSubview:_scrollerView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _titleLabel = [[UILabel alloc]init];
    [_scrollerView addSubview:_titleLabel];
    
    NSString *userAgreementPath = [[NSBundle mainBundle]pathForResource:@"userAgreement" ofType:@"txt"];
    NSString *text = [NSString stringWithContentsOfFile:userAgreementPath encoding:NSUTF8StringEncoding error:nil];
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.frame) - 30, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],NSForegroundColorAttributeName : [UIColor colorWithString:@"202020"]} context:nil].size;
    _scrollerView.contentSize = CGSizeMake(CGRectGetWidth(_scrollerView.frame), textSize.height + 100);
    
    _titleLabel.frame = CGRectMake(15, 25, textSize.width, textSize.height);
    _titleLabel.text = text;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
}

-(void)viewWillLayoutSubviews{

    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.textColor = [UIColor colorWithString:@"333333"];
}


-(UIView *)leftBarButton{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_backOn"] forState:UIControlStateHighlighted];
    return button;
}

-(void)back:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)dealloc{
    NSLog(@"userAgreementDealloc");
}

@end
