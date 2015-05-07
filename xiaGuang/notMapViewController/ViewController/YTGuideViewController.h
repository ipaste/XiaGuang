//
//  YTGuideViewController.h
//  虾逛
//
//  Created by YunTop on 15/4/13.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YTGuideDelegate <NSObject>
@optional
- (void)dismissGuideViewController;
@end

@interface YTGuideViewController : UIViewController
@property (weak ,nonatomic) id <YTGuideDelegate> delegate;
@end

@interface YTGuideView : UIScrollView
-(instancetype)initWithImages:(NSArray *)images;
@end


