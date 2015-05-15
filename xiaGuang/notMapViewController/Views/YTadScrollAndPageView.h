//
//  YTadScrollAndPageView.h
//  虾逛
//
//  Created by Yuntop on 15/4/30.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YTscrollViewDelegate;

@interface YTadScrollAndPageView : UIView<UIScrollViewDelegate> {
    __unsafe_unretained id <YTscrollViewDelegate> _delegate;
}
@property (nonatomic,assign) id <YTscrollViewDelegate> delegate;

@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,strong) NSMutableArray *imgArr;
@property (nonatomic,strong) UIScrollView *adScrollView;
@property (nonatomic,strong) UIPageControl *pageControl;

-(void)shouldAutoShow:(BOOL)shouldStart;
@end

@protocol YTscrollViewDelegate <NSObject>

@optional
- (void)didClickPage:(YTadScrollAndPageView *)view atIndex:(NSInteger)index;

@end