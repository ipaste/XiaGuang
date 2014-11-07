//
//  YTNavigationBar.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-16.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTNavigationBar;
@protocol YTNavigationBarDelegate <NSObject>
@optional
-(void)backButtonClicked;
-(void)searchButtonClicked;
@end
@interface YTNavigationBar : UIView
@property (weak,nonatomic) id<YTNavigationBarDelegate> delegate;
@property (weak,nonatomic) NSString *backTitle;
@property (weak,nonatomic) NSString *titleName;
-(void)changeSearchButton;

-(void)changeBackButton;
@end
