//
//  YTSaleView.h
//  虾逛
//
//  Created by YunTop on 15/4/23.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@class YTSaleView;

@protocol YTSaleDelegate <NSObject>

@optional
/**
 *  协议方法: 开始点击SaleView
 *
 *  @param saleView 当前响应的SaleView
 */
- (void)touchBeganWithSaleView:(YTSaleView *)saleView;

/**
 *  协议方法: 结束点击SaleView
 *
 *  @param saleView 当前响应的SaleView
 */
- (void)touchEndWithSaleView:(YTSaleView *)saleView;
@end

@interface YTSaleView : UIView

@property (weak ,nonatomic)id <YTSaleDelegate> delegate;

/**
 *  设置显示信息
 *
 *  @param image        商铺图片
 *  @param merchantName 商铺名称
 *  @param saleInfo     特价信息
 *  @param isSole       是否独家
 */
- (void)setSaleViewWithMerchantImage:(UIImage *)image
                        merchantName:(NSString *)merchantName
                            saleInfo:(NSString *)saleInfo
                              isSole:(BOOL)isSole;
@end
