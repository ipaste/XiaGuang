//
//  YTadScrollAndPageView.m
//  虾逛
//
//  Created by Yuntop on 15/4/30.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#import "YTadScrollAndPageView.h"
#import "YTActiveDetailViewController.h"
@interface YTadScrollAndPageView ()<UIScrollViewDelegate> {
    UIScrollView *_scrollerView;
    
    NSArray *_images;
    
    NSMutableArray *_imageViews;
    
    NSTimer *_timer;
    
    BOOL _isManualSwitch;
}

@end

@implementation YTadScrollAndPageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _images = [NSMutableArray array];
        _imageViews = [NSMutableArray array];
        
        _scrollerView = [[UIScrollView alloc]init];
        _scrollerView.showsHorizontalScrollIndicator = NO;
        _scrollerView.showsVerticalScrollIndicator = NO;
        _scrollerView.pagingEnabled = YES;
        _scrollerView.userInteractionEnabled = true;
        _scrollerView.delegate = self;
        _scrollerView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectedMallActivity:)];
        [_scrollerView addGestureRecognizer:tap];
        
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.userInteractionEnabled = false;
        //小黑点选中跟未选中的颜色
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_on"]];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_off"]];
    
        for (NSInteger index = 0; index < 3; index++) {
            UIImageView *imageView = [[UIImageView alloc]init];
            [_imageViews addObject:imageView];
            [_scrollerView addSubview:imageView];
        }
        
        [self addSubview:_scrollerView];
        [self insertSubview:_pageControl aboveSubview:_scrollerView];
        
        _isManualSwitch = true;
        _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(bannerSwitch:) userInfo:_scrollerView repeats:true];
    }
    return self;
}

- (void)layoutSubviews{
    CGRect frame = _scrollerView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = CGRectGetWidth(self.frame);
    frame.size.height = CGRectGetHeight(self.frame);
    _scrollerView.frame = frame;
    
    frame = _pageControl.frame;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetHeight(self.frame) - 20;
    frame.size.width  = CGRectGetWidth(self.frame) / 2;
    frame.size.height = 20;
    _pageControl.frame = frame;
    
    for (NSInteger index = 0; index < _imageViews.count; index++) {
        UIImageView *imageView = _imageViews[index];
        CGRect frame = imageView.frame;
        frame.origin.x = index * CGRectGetWidth(self.frame);
        frame.origin.y = 0;
        frame.size.width = CGRectGetWidth(self.frame);
        frame.size.height = CGRectGetHeight(self.frame);
        imageView.frame = frame;
    }
 
    
    _pageControl.center = CGPointMake(CGRectGetWidth(self.frame) / 2, _pageControl.center.y);
    
    _scrollerView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * _imageViews.count, CGRectGetHeight(self.frame));
    
    _scrollerView.contentOffset = CGPointMake(CGRectGetWidth(_scrollerView.frame), 0);
}


-(void)setImages:(NSArray *)images{
    if (images == nil) {
        return;
    }
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = images.count;
    _images  = images.copy;
    [self setNeedsLayout];
    
    if (images.count == 1) {
        _scrollerView.scrollEnabled = false;
    }
    
    for (NSInteger index = 0; index < _imageViews.count; index++) {
        UIImageView *imageView = _imageViews[index];
        if (index < _images.count) {
            imageView.image = _images[index];
        }else{
            imageView.image = _images[0];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isManualSwitch) {
        [self toggleBanner:scrollView];
    }
}


-(void)bannerSwitch:(NSTimer *)timer{
    _isManualSwitch = NO;
    UIScrollView *scrollView = timer.userInfo;
    [UIView animateWithDuration:0.5 animations:^{
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x + CGRectGetWidth(scrollView.frame), scrollView.contentOffset.y);
    } completion:^(BOOL finished) {
        [self toggleBanner:scrollView];
        _isManualSwitch = YES;
    }];
}

- (void)toggleBanner:(UIScrollView *)scrollView{
    BOOL isSwitch = false;
    if (scrollView.contentOffset.x / scrollView.frame.size.width == 0 ) {
        //上一张
        _pageControl.currentPage = _pageControl.currentPage - 1 < 0 ? _images.count: _pageControl.currentPage - 1;
        scrollView.contentOffset = CGPointMake(CGRectGetWidth(scrollView.frame), 0);
        isSwitch = true;
        
    }else if (scrollView.contentOffset.x / scrollView.frame.size.width == 2){
        //下一张
        _pageControl.currentPage = _pageControl.currentPage + 1 > _images.count - 1 ? 0 : _pageControl.currentPage + 1;
        scrollView.contentOffset = CGPointMake(CGRectGetWidth(scrollView.frame), 0);
        isSwitch = true;
    }

    if (isSwitch) {
        for (int i = 0; i < _imageViews.count; i++) {
            UIImageView *curImageView = _imageViews[i];
            int num =  (i % _images.count + (int)_pageControl.currentPage) % _images.count;
            curImageView.image = _images[num];
        }
    }
}


- (void)selectedMallActivity:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(didClickPage:atIndex:)]){
        [self.delegate didClickPage:self atIndex:_pageControl.currentPage];
    }
}


- (void)removeFromSuperview{
    [super removeFromSuperview];
    [_timer invalidate];
}

@end
