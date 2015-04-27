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
    YTStateTypeNoNetWork,
    YTStateTypeLoading,
    YTStateTypeNotFound
};

@interface YTStateView : UIView
@property (assign ,nonatomic) YTStateType type;


/**
 *  初始化方法
 *
 *  @param type 传入一个状态，显示不同画面
 *
 *  @return 返回一个YTStateView对象
 */
- (instancetype)initWithStateType:(YTStateType)type;

/**
 *  开始显示加载图片，当Type为YTStateTypeLoading的时候可用
 */
- (void)startAnimation;
- (void)stopAnimation;
@end
