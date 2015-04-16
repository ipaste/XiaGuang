//
//  YTGuideViewController.m
//  虾逛
//
//  Created by YunTop on 15/4/13.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTGuideViewController.h"

#define MAIN_SCREEN [UIScreen mainScreen].bounds

@interface YTGuideViewController()<UIScrollViewDelegate>{
    NSArray *_images;
    UIButton *_dismissButton;
}
- (void)dismissGuideViewController;
@end

@implementation YTGuideViewController
- (void)viewDidLoad{
    NSMutableArray *images = [NSMutableArray new];
    for (NSInteger index = 0; index < 4; index++) {
        NSString *imageName = [NSString stringWithFormat:@"help%ld.jpg",index + 1];
        UIImage * image = [UIImage imageNamed:imageName];
        [images addObject:image];
    }
    _images = images.copy;
    [images removeAllObjects];
    YTGuideView *view = [[YTGuideView alloc]initWithImages:_images];
    view.delegate = self;
    [self.view addSubview:view];
    
    _dismissButton = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(MAIN_SCREEN) - 63, 160, 45)];
    _dismissButton.alpha = 0.0f;
    [_dismissButton setBackgroundImage:[UIImage imageNamed:@"btn_start"] forState:UIControlStateNormal];
    [_dismissButton setBackgroundImage:[UIImage imageNamed:@"btn_startOn"] forState:UIControlStateHighlighted];
    [_dismissButton addTarget:self action:@selector(dismissGuideViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_dismissButton];
    
}

-(void)viewDidLayoutSubviews{
    _dismissButton.center = CGPointMake(self.view.center.x, _dismissButton.center.y);
}

- (void)dismissGuideViewController{
    if ([_delegate respondsToSelector:@selector(dismissGuideViewController)]) {
        [_delegate dismissGuideViewController];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat alpha = 0.0f;
    NSTimeInterval duration = 0.0;
    if (offsetY == CGRectGetHeight(MAIN_SCREEN) * (_images.count - 1)) {
        // this is last Image
        alpha = 1.0f;
        duration = 0.5;
    }else{
        // not last Image
        alpha = 0.0f;
        duration = 0.0;
    }
    
    [UIView animateWithDuration:duration animations:^{
        _dismissButton.alpha = alpha;
    }];
}

-(BOOL)prefersStatusBarHidden{
    return true;
}

@end




#pragma Mark YTGuideView
@implementation YTGuideView
- (instancetype)init{
    return [self initWithImages:nil];
}

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithImages:nil];
}

- (instancetype)initWithImages:(NSArray *)images{
    self = [super initWithFrame:MAIN_SCREEN];
    if (self) {

        for (NSInteger index = 0; index < images.count; index++) {
            UIImageView *imgeView = [[UIImageView alloc]initWithFrame:CGRectMake(0, index *  CGRectGetHeight(MAIN_SCREEN), CGRectGetWidth(MAIN_SCREEN), CGRectGetHeight(MAIN_SCREEN))];
            imgeView.image = images[index];
            [self addSubview:imgeView];
        }
        
        self.contentSize = CGSizeMake(CGRectGetWidth(MAIN_SCREEN), CGRectGetHeight(MAIN_SCREEN) * images.count);
        self.showsVerticalScrollIndicator = false;
        self.showsHorizontalScrollIndicator = false;
        self.pagingEnabled = true;
        self.bounces = false;
    }
    return self;
}
@end