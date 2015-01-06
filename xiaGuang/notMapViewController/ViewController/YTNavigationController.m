//
//  YTNavtgationController.m
//  xiaGuang
//
//  Created by YunTop on 14/10/29.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTNavigationController.h"
#define BIGGER_THEN_IPHONE5 ([[UIScreen mainScreen]currentMode].size.height >= 1136.0f ? YES : NO)
@implementation YTNavigationController{
    YTHomeViewController *_homeVC;
    UIViewController *_displayController;
    UIImageView *_backgroundView;
    BOOL _isReGet;
}

-(instancetype)initWithCreateHomeViewController{
    _homeVC = [[YTHomeViewController alloc]init];
    self = [super initWithRootViewController:_homeVC];
    if (self) {
        self.delegate = self;
        _isReGet = YES;
    }
    return self;
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    _displayController = viewController;
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    if([viewController isMemberOfClass:[YTMallInfoViewController class]]){                        
    }else if([viewController isMemberOfClass:[YTSettingViewController class]]){
        _backgroundView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        if (BIGGER_THEN_IPHONE5) {
            _backgroundView.image = [UIImage imageNamed:@"home_bg1136@2x.jpg"];
        }else{
            _backgroundView.image = [UIImage imageNamed:@"home_bg960@2x.jpg"];
        }
        [viewController.view insertSubview:_backgroundView atIndex:0];
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        navigationController.navigationBar.clipsToBounds = YES;
        [navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
        navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated{
    if ([_displayController isMemberOfClass:[YTMallInfoViewController class]]){
        
    }else if ([_displayController isMemberOfClass:[YTSettingViewController class]]){
        [_backgroundView removeFromSuperview];
    }
    return [super popViewControllerAnimated:animated];
}

-(void)dealloc{
    NSLog(@"ytNavigationController destroyed");
}
@end
