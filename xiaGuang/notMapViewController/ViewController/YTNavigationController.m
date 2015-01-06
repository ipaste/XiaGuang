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
    if ([viewController isEqual:_homeVC]) {
        navigationController.navigationBar.clipsToBounds = true;
        navigationController.navigationBar.tintColor = [UIColor colorWithString:@"e65e37"];
        [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
    }else if([viewController isMemberOfClass:[YTMallInfoViewController class]]){
//        navigationController.navigationBar.clipsToBounds = NO;
//        navigationController.navigationBar.tintColor = [UIColor whiteColor];
//        id<YTMall> mall = [(YTMallInfoViewController *)viewController mall];
//        if (mall) {
//            [mall
//             getInfoBackgroundImageWithCallBack:^(UIImage *result, NSError *error) {
//                 [navigationController.navigationBar setBackgroundImage:result forBarMetrics:UIBarMetricsDefault];
//             }];
//            if (_isReGet) {
//                _isReGet = NO;
//                [mall getMallInfoTitleCallBack:^(UIImage *result, NSError *error) {
//                    UIView *titleView = [[UIView alloc]initWithFrame:CGRectZero];
//                    UIImageView *titleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, result.size.width / 2, result.size.height / 2)];
//                    titleImageView.center = titleView.center;
//                    titleImageView.image = result;
//                    [titleView addSubview:titleImageView];
//                    viewController.navigationItem.titleView = titleView;
//                }];
//            }
//        }
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
    }else{
        navigationController.navigationBar.clipsToBounds = NO;
        [navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"all_bg_navbar"] forBarMetrics:UIBarMetricsDefault];
    }
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated{
    if ([_displayController isMemberOfClass:[YTMallInfoViewController class]]){
        _isReGet = YES;
    }else if ([_displayController isMemberOfClass:[YTSettingViewController class]]){
        [_backgroundView removeFromSuperview];
    }
    return [super popViewControllerAnimated:animated];
}

-(void)dealloc{
    NSLog(@"ytNavigationController destroyed");
}
@end
