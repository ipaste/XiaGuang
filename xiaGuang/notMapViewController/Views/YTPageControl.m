//
//  YTPageControl.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-16.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTPageControl.h"
@interface YTPageControl (){
    NSMutableArray *_pageCount;
}
@end
@implementation YTPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfPages = 0;
    }
    return self;
}

-(void)setNumberOfPages:(NSInteger)numberOfPages{
    _pageCount = [NSMutableArray array];
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10 * numberOfPages, 10)];
    backgroundView.center = CGPointMake(self.center.x, backgroundView.center.y);
    [self addSubview:backgroundView];
    for (int i = 0 ; i < numberOfPages; i++) {
        UIView *pageView = [[UIView alloc]initWithFrame:CGRectMake(i % numberOfPages * 15, 0, 8, 8)];
        pageView.layer.borderWidth = 1;
        pageView.tag = i;
        pageView.layer.borderColor = [UIColor whiteColor].CGColor;
        pageView.layer.cornerRadius = CGRectGetHeight(pageView.frame) / 2;
        [backgroundView addSubview:pageView];
        [_pageCount addObject:pageView];
    }
    _numberOfPages = numberOfPages;
}

-(void)setCurrentPage:(NSInteger)currentPage{
    if (currentPage < 0) {
        currentPage = self.numberOfPages - 1;
    }else if(currentPage > self.numberOfPages - 1){
        currentPage = 0;
    }
    for (UIView *view in _pageCount) {
        view.backgroundColor = [UIColor clearColor];
        if (view.tag == currentPage) {
            view.backgroundColor = [UIColor whiteColor];
        }
    }
    _currentPage = currentPage;
}

-(void)layoutSubviews{
    
}


@end
