//
//  YTMallPosistionViewController.m
//  xiaGuang
//
//  Created by YunTop on 14/11/5.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTMallPosistionViewController.h"

@implementation YTMallPosistionViewController{
    UIView *_detailsView;
//    UIImageView *_mapImageView;
//    UILabel *_phoneNumberLabel;
    UILabel *_addressLabel;
    NSURL *_url;
    UIWebView *_webView;
    UIView *_labelView;
    UILabel *_mallNameLabel;
}

//euwen: use url rather than img
-(instancetype)initWithMallCoordinate:(CLLocationCoordinate2D )coordinate address:(NSString *)address mallName:(NSString *)mallName{

    self = [super init];
    if (self) {
        self.navigationItem.title = @"商圈位置";
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftBarButton]];
        self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
        self.view.clipsToBounds = YES;
        
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        _webView.delegate = self;
        NSString * urlString = [NSString stringWithFormat:@"http://m.amap.com/?q=%f,%f",coordinate.latitude,coordinate.longitude];
        
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        _url = [NSURL URLWithString:urlString];
        
        [self.view addSubview:_webView];
        
        //add mall name to the label
        _labelView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_webView.frame), CGRectGetMaxY(self.navigationController.navigationBar.frame)+110)];
       // _labelView.backgroundColor = [UIColor darkGrayColor];
        _labelView.layer.contents = (id)[UIImage imageNamed:@"bgTop_addressMall"].CGImage;
        [_webView addSubview:_labelView];
        
        _mallNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(self.navigationController.navigationBar.frame)+30, CGRectGetWidth(_webView.frame)-18, CGRectGetMaxY(self.navigationController.navigationBar.frame)+110)];
        _mallNameLabel.text = mallName;
        
        _mallNameLabel.textColor = [UIColor colorWithString:@"ffffff"];
        _mallNameLabel.textAlignment = NSTextAlignmentLeft;
        _mallNameLabel.font = [UIFont systemFontOfSize:16];
        [_labelView addSubview:_mallNameLabel];
        
        UIImageView *mapCopyright = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"amap_copyright"]];
        mapCopyright.center = CGPointMake(CGRectGetWidth(_labelView.frame)-18-CGRectGetWidth(mapCopyright.frame)/2, _mallNameLabel.center.y);
        [_labelView addSubview:mapCopyright];
        
        
        //footer
        _detailsView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_webView.frame) - 60, CGRectGetWidth(_webView.frame), 60)];
        //_detailsView.backgroundColor = [UIColor darkGrayColor];
        _detailsView.layer.contents = (id)[UIImage imageNamed:@"bgFooter_addressMall"].CGImage;
        [_webView addSubview:_detailsView];

        //address
        _addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, CGRectGetHeight(_detailsView.frame)-50, CGRectGetWidth(_detailsView.frame), 40)];
        _addressLabel.text = address;
        _addressLabel.textColor = [UIColor colorWithString:@"ffffff"];
        _addressLabel.font = [UIFont systemFontOfSize:15];
        [_detailsView addSubview:_addressLabel];
        
        
        UIImageView *addressIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_location"]];
        addressIcon.center = CGPointMake(18 + CGRectGetWidth(addressIcon.frame)/2, _addressLabel.center.y);
        [_detailsView addSubview:addressIcon];

    }

    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_url != nil){
        NSURLRequest *request = [NSURLRequest requestWithURL:_url];
        [_webView loadRequest:request];
    }
}


-(UIView *)leftBarButton{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_backOn"] forState:UIControlStateHighlighted];
    return button;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
}

-(void)back:(UIButton *)sender{
    _url = nil;
    [_webView stopLoading];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSURLCache sharedURLCache]removeAllCachedResponses];
    });
    [self.navigationController popViewControllerAnimated:true];
}

-(void)dealloc{
    NSLog(@"dealloc MALLPOSITIONVIEW");
   
}
@end
