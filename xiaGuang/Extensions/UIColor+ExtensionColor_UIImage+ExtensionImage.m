//
//  UIColor+YTColor.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-8-28.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"

@implementation UIColor (YTColor)
+ (UIColor *)colorWithString:(NSString *)colorString
{
    return [self colorWithString:colorString alpha:1.0];
}
+ (UIColor *)colorWithString:(NSString *)colorString alpha:(CGFloat)alpha
{
    if (colorString == nil || colorString.length < 6) {
        return nil;
    }
    
    if ([colorString rangeOfString:@"#"].length <= 0) {
        colorString = [NSString stringWithFormat:@"#%@",colorString];
    }
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 1;
    [[NSScanner scannerWithString:[colorString substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[colorString substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[colorString substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}
@end

@implementation UIImage (YTImage)
+ (UIImage *)imageWithImageName:(NSString *)name andTintColor:(UIColor *)tintColor
{
    
    UIImage *tempImage = [UIImage imageNamed:name];
    UIGraphicsBeginImageContextWithOptions(tempImage.size, NO, 0.0f);
    
    [tintColor setFill];
    
    CGRect bouns = CGRectMake(0, 0, tempImage.size.width, tempImage.size.height);
    UIRectFill(bouns);
    
    [tempImage drawInRect:bouns blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    UIImage *tintImage =  UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return tintImage;
}

+ (UIImage *)imageRotateOneHundredAndEightyDegreesWithImageName:(NSString *)name
{
    UIImage *tempImage = [UIImage imageNamed:name];
    
    UIGraphicsBeginImageContext(tempImage.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, tempImage.size.width / 2, tempImage.size.height / 2);
    CGContextRotateCTM(context, M_PI);
    CGContextTranslateCTM(context, -tempImage.size.width / 2, -tempImage.size.height / 2);
    
    [tempImage drawInRect:CGRectMake(0, 0, tempImage.size.width, tempImage.size.height)];
    
    UIImage *rotateImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rotateImage;
}

+ (UIImage *)originImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
+ (UIImage *)imageFromImage:(UIImage *)image rect:(CGRect)rect{
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    return [UIImage imageWithCGImage:newImageRef];
}



@end