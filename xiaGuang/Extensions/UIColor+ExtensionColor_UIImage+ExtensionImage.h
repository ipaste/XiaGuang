//
//  UIColor+YTColor.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-28.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIColor (YTColor)
+ (UIColor *)colorWithString:(NSString *)colorString;
+ (UIColor *)colorWithString:(NSString *)colorString alpha:(CGFloat)alpha;
@end


@interface UIImage (YTImage)
+ (UIImage *)imageWithImageName:(NSString *)name andTintColor:(UIColor *)tintColor;
+ (UIImage *)imageRotateOneHundredAndEightyDegreesWithImageName:(NSString *)name;
+ (UIImage *)imageWithImageName:(NSString *)name rotate:(CGFloat)rotate;
+ (UIImage *)originImage:(UIImage *)image scaleToSize:(CGSize)size;
+ (UIImage *)imageFromImage:(UIImage *)image rect:(CGRect)rect;

@end