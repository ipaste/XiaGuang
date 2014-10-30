//
//  YTPanel.h
//  xiaGuang
//
//  Created by YunTop on 14-10-24.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YTPanel;
@protocol YTPanelDelegate <NSObject>
-(void)clickedPanelAtIndex:(NSInteger)index;
@end

@interface YTPanel : UIView
@property (weak ,nonatomic)id<YTPanelDelegate> delegate;

// items for NSString class the Array
-(instancetype)initWithFrame:(CGRect)frame items:(NSArray *)itmes;
-(void)setItemsTheImage:(NSArray *)images highlightImages:(NSArray *)highlightImages;
-(void)setBluetoothState:(BOOL)on;
-(void)startAnimationWithBackgroundAndCircle;
-(void)stopAnimationWithBackgroundAndCircle;
@end
