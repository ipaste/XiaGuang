//
//  YTH5ViewController.h
//  虾逛
//
//  Created by YunTop on 15/3/9.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@interface YTH5ViewController : UIViewController<UIWebViewDelegate,WKNavigationDelegate>
-(instancetype)initWithH5_url:(NSURL *)h5_url;
@end
