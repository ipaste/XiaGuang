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

@interface YTadScrollAndPageView () {
    UIView *_leftView;
    UIView *_midView;
    UIView *_rightView;
    UIImage *_activeImg;
    UIImage *_inactiveImg;
    
    NSTimer *_adTimer;
}

@end

@implementation YTadScrollAndPageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _adScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH,130)];
        _adScrollView.delegate = self;
        _adScrollView.contentSize = CGSizeMake(SCREEN_WIDTH *3, 0.0);
        _adScrollView.showsHorizontalScrollIndicator = NO;
        _adScrollView.showsVerticalScrollIndicator = NO;
        _adScrollView.pagingEnabled = YES;
        _adScrollView.bounces = NO;
        _adScrollView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_adScrollView];
        
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0.0,CGRectGetMaxY(_adScrollView.frame) -19.0, 12.0, 12.0)];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_on"]];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_off"]];
        [self addSubview:_pageControl];
    }
    return self;
}

- (void)setImgArr:(NSMutableArray *)imgArr {
    if (imgArr) {
        _imgArr = imgArr;
        _currentPage = 0;
        _pageControl.numberOfPages = _imgArr.count;
    }
    [self reloadData];
}

- (void)reloadData {
    [_leftView removeFromSuperview];
    [_midView removeFromSuperview];
    [_rightView removeFromSuperview];
    
    if (_currentPage == 0) {
        _leftView = [_imgArr lastObject];
        _midView = [_imgArr objectAtIndex:_currentPage];
        _rightView = [_imgArr objectAtIndex:_currentPage+1];
    }
    else if (_currentPage == _imgArr.count -1) {
        _leftView = [_imgArr objectAtIndex:_currentPage -1];
        _midView = [_imgArr objectAtIndex:_currentPage];
        _rightView = [_imgArr firstObject];
    }
    else {
        _leftView = [_imgArr objectAtIndex:_currentPage -1];
        _midView = [_imgArr objectAtIndex:_currentPage];
        _rightView = [_imgArr objectAtIndex:_currentPage +1];
    }
    
    _leftView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, 130);
    _midView.frame = CGRectMake(SCREEN_WIDTH, 0.0, SCREEN_WIDTH, 130);
    _rightView.frame = CGRectMake(SCREEN_WIDTH *2, 0.0, SCREEN_WIDTH, 130);
    [_adScrollView addSubview:_leftView];
    [_adScrollView addSubview:_midView];
    [_adScrollView addSubview:_rightView];
    
    _pageControl.currentPage = _currentPage;
    
    _adScrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_adTimer invalidate];
    _adTimer = nil;
    _adTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(showNextImg) userInfo:nil repeats:YES];
    
    float x = _adScrollView.contentOffset.x;
    if (x <=0) {
        if (_currentPage -1 <0) {
            _currentPage = _imgArr.count -1;
        }else {
            _currentPage --;
        }
    }
    
    if (x >= SCREEN_WIDTH *2) {
        if (_currentPage == _imgArr.count -1) {
            _currentPage = 0;
        } else {
            _currentPage ++;
        }
    }
    [self reloadData];
}

- (void)shouldAutoShow:(BOOL)shouldStart {
    if (shouldStart) {
        if (!_adTimer) {
            _adTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(showNextImg) userInfo:nil repeats:YES];
        }
    }
    else {
        if (_adTimer.isValid) {
            [_adTimer invalidate];
            _adTimer = nil;
        }
    }
}

- (void)showNextImg {
    if (_currentPage == _imgArr.count -1) {
        _currentPage = 0;
    } else {
        _currentPage ++;
    }
    [self reloadData];
}

@end
