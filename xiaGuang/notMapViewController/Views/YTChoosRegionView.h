//
//  YTChoosRegionView.h
//  虾逛
//
//  Created by YunTop on 15/4/17.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTCityAndRegion.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@class YTChoosRegionView;
@protocol YTChoosRegionDelegate <NSObject>
@optional
- (void)hideChoosRegionView;
// region == nil 为全城
- (void)selectRegion:(YTRegion *)region;
@end

@interface YTChoosRegionView : UIView
@property (weak,nonatomic)id <YTChoosRegionDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                         city:(YTCity *)city;

- (void)show;
- (void)hide;
@end
