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
    if ([viewController isEqual:_homeVC] || [viewController isMemberOfClass:[YTSettingViewController class]] || [viewController isMemberOfClass:[YTMallViewController class]]) {
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
        navigationController.navigationBar.clipsToBounds = YES;
        navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        if (BIGGER_THEN_IPHONE5) {
            backgroundView.image = [UIImage imageNamed:@"home_bg1136@2x.jpg"];
        }else{
            backgroundView.image = [UIImage imageNamed:@"home_bg960@2x.jpg"];
        }
        [viewController.view insertSubview:backgroundView atIndex:0];
    }else if([viewController isMemberOfClass:[YTMallInfoViewController class]]){
        navigationController.navigationBar.clipsToBounds = NO;
        [[(YTMallInfoViewController *)viewController mall] getInfoBackgroundImageWithCallBack:^(UIImage *result, NSError *error) {
            [navigationController.navigationBar setBackgroundImage:result forBarMetrics:UIBarMetricsDefault];
        }];
        if (_isReGet) {
            _isReGet = NO;
            [[(YTMallInfoViewController *)viewController mall] getMallInfoTitleCallBack:^(UIImage *result, NSError *error) {
                UIView *titleView = [[UIView alloc]initWithFrame:CGRectZero];
                UIImageView *titleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, result.size.width / 2, result.size.height / 2)];
                titleImageView.center = titleView.center;
                titleImageView.image = result;
                [titleView addSubview:titleImageView];
                viewController.navigationItem.titleView = titleView;
            }];
        }
    }else{
        navigationController.navigationBar.clipsToBounds = NO;
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"all_bg_navbar-1"] forBarMetrics:UIBarMetricsDefault];
    }
    
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated{
    if ([_displayController isMemberOfClass:[YTSettingViewController class]]) {
        animated = NO;
    }else if ([_displayController isMemberOfClass:[YTMallInfoViewController class]]){
        _isReGet = YES;
    }
    return [super popViewControllerAnimated:animated];
}
@end
