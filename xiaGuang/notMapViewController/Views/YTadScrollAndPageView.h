//
//  YTadScrollAndPageView.h
//  虾逛
//
//  Created by Yuntop on 15/4/30.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YTScrollViewDelegate;

@interface YTadScrollAndPageView : UIView
@property (nonatomic,assign) id <YTScrollViewDelegate> delegate;
@property (nonatomic,strong) NSArray *images;
@property (nonatomic,strong) UIPageControl *pageControl;

@end

@protocol YTScrollViewDelegate <NSObject>

@optional
- (void)didClickPage:(YTadScrollAndPageView *)view atIndex:(NSInteger)index;

@end