//
//  YTStateView.h
//  虾逛
//
//  Created by YunTop on 15/4/15.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"

typedef NS_ENUM(NSInteger, YTStateType) {
    YTStateTypeNormal,
    YTStateTypeNotNetWork,
    YTStateTypeLoading,
    YTStateTypeNotFound
};

@interface YTStateView : UIView
@property (assign ,nonatomic) YTStateType type;

- (instancetype)initWithStateType:(YTStateType)type;

// type 为YTStateTypeLoading的时候可用
- (void)startAnimation;
- (void)stopAnimation;
@end
