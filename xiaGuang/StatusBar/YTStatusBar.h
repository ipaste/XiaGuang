//
//  YTStatusBar.h
//  虾逛
//
//  Created by YunTop on 15/1/22.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, YTStatusBarType) {
    YTStatusBarTypeDownloadMessage,
    YTStatusBarTypeUpdateMessage,
    YTStatusBarTypeDone
};


@interface YTStatusBar : UIWindow
+(instancetype)defaultStatusBar;
-(void)changeMessageType:(YTStatusBarType )type;

@end

@interface YTStatusViewController : UIViewController
-(void)changeMessage:(NSString *)message;
@end
