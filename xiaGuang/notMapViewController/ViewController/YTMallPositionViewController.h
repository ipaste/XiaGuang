//
//  YTMallPositionViewController.h
//  xiaGuang
//
//  Created by YunTop on 14/11/5.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import <CoreLocation/CoreLocation.h>

@interface YTMallPositionViewController : UIViewController<UIWebViewDelegate>
//-(instancetype)initWithImage:(UIImage *)image address:(NSString *)address phoneNumber:(NSString *)phoneNumber;

-(instancetype)initWithMallCoordinate:(CLLocationCoordinate2D )coordinate address:(NSString *)address mallName:(NSString *)mallName;

@end
