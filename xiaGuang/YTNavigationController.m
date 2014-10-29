//
//  YTNavtgationController.m
//  xiaGuang
//
//  Created by YunTop on 14/10/29.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTNavigationController.h"

@implementation YTNavigationController{
    YTHomeViewController *_homeVC;
}
-(instancetype)initWithCreateHomeViewController{
    _homeVC = [[YTHomeViewController alloc]init];
    self = [super initWithRootViewController:_homeVC];
    if (self) {
        self.delegate = self;
    }
    return self;
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController isEqual:_homeVC]) {
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
        navigationController.navigationBar.clipsToBounds = YES;
        navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        
    }else if([viewController isMemberOfClass:[YTMallInfoViewController class]]){
        [[(YTMallInfoViewController *)viewController mall] getInfoBackgroundImageWithCallBack:^(UIImage *result, NSError *error) {
            [navigationController.navigationBar setBackgroundImage:result forBarMetrics:UIBarMetricsDefault];
        }];
    }else{
        navigationController.navigationBar.clipsToBounds = NO;
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"all_bg_navbar-1"] forBarMetrics:UIBarMetricsDefault];
    }
}
@end
