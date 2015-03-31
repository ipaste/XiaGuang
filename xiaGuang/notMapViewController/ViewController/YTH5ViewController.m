//
//  YTH5ViewController.m
//  虾逛
//
//  Created by YunTop on 15/3/9.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTH5ViewController.h"
#define CURRENTVERSION [[UIDevice currentDevice]systemVersion].floatValue
@implementation YTH5ViewController{
    WKWebView *_8_webView;
    UIWebView *_7_webView;
    UIProgressView *_progressView;
    NSURLRequest *_request;
}
-(instancetype)initWithH5_url:(NSURL *)h5_url{
    self = [super init];
    if (self) {
        _request = [NSURLRequest requestWithURL:h5_url];
        
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    if (CURRENTVERSION < 8.0) {
        _7_webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
        [_7_webView loadRequest:_request];
        _7_webView.delegate = self;
        [self.view addSubview:_7_webView];
    }else{
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 2)];
        _8_webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
        [self.view addSubview:_8_webView];
        [self.view addSubview:_progressView];
        [_8_webView loadRequest:_request];
        _8_webView.navigationDelegate = self;
        [_8_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
    self.navigationController.navigationBar.clipsToBounds = false;
    self.navigationItem.title = @"虾逛";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bgTop_addressMall"] forBarMetrics:UIBarMetricsDefault];
}

-(UIView *)leftBarButton{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_backOn"] forState:UIControlStateHighlighted];
    return button;
}

-(void)back:(UIButton *)sender{
    [_8_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    self.navigationController.navigationBar.clipsToBounds = true;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark IOS_7


#pragma mark IOS_8
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    _progressView.progress = 0.0;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]){
        _progressView.hidden = _8_webView.estimatedProgress == 1;
        [_progressView setProgress:(float)_8_webView.estimatedProgress animated:true];
    }
}

-(void)dealloc{
    NSLog(@"h5 dealloc");
}

@end
