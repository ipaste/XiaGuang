//
//  YTSearchView.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-16.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMall.h"
@class YTSearchView;
@protocol YTSearchViewDelegate <NSObject>
@optional
-(void)searchCancelButtonClicked;
@required
-(void)selectedMerchantName:(NSString *)name;
@end

@interface YTSearchView : UIView
@property (weak,nonatomic) id<YTSearchViewDelegate> delegate;

// mall == nil ? searchAllMall : searchMall
-(instancetype)initWithMall:(id<YTMall>)mall placeholder:(NSString *)placeholder;


//image == nil 背景为透明
-(void)setBackgroundImage:(UIImage *)image;

-(void)addInNavigationBar:(UINavigationBar *)naviBar show:(BOOL)show;
-(void)addInView:(UIView *)view show:(BOOL)show;

-(void)showSearchViewWithAnimation:(BOOL)animation;
-(void)hideSearchViewWithAnimation:(BOOL)animation;
@end
