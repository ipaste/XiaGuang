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
}

-(instancetype)initWithCreateHomeViewController{
    _homeVC = [[YTHomeViewController alloc]init];
    self = [super initWithRootViewController:_homeVC];
    if (self) {
        
        self.delegate = self;
        self.navigationBar.barStyle = UIBarStyleBlack;
    }
    return self;
}



-(void)dealloc{
    NSLog(@"ytNavigationController destroyed");
}
@end
