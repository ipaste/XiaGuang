//
//  YTStatusBar.m
//  虾逛
//
//  Created by YunTop on 15/1/22.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTStatusBar.h"

#define STATUS_WIDTH 100
@implementation YTStatusBar{
    YTStatusViewController *_rootVC;
}

+(instancetype)defaultStatusBar{
    static dispatch_once_t onceToken;
    static YTStatusBar *statusBar;
    dispatch_once(&onceToken, ^{
        statusBar = [[YTStatusBar alloc]init];
    });
    return statusBar;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) + STATUS_WIDTH, 0, STATUS_WIDTH, CGRectGetHeight([UIApplication sharedApplication].statusBarFrame));
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.backgroundColor = [UIColor clearColor];
        _rootVC = [[YTStatusViewController alloc]init];
        self.rootViewController = _rootVC;
    }
    return self;
}
-(void)changeMessageType:(YTStatusBarType )type{
    switch (type) {
        case YTStatusBarTypeDownloadMessage:
            [_rootVC changeMessage:@"正在更新地图数据"];
            break;
            
        case YTStatusBarTypeUpdateMessage:
            [_rootVC changeMessage:@"正在更新本地数据"];
            break;
            
        case YTStatusBarTypeDone:
            [_rootVC changeMessage:@"更新完成"];
            [NSTimer timerWithTimeInterval:1 target:self selector:@selector(hideStatusBar:) userInfo:nil repeats:NO];
            break;
    }
    
    [UIView animateWithDuration:.5 animations:^{
        CGRect frame = self.frame;
        frame.origin.x = CGRectGetWidth([UIScreen mainScreen].bounds) - STATUS_WIDTH;
        self.frame = frame;
    }];
}
-(void)hideStatusBar:(NSTimer *)timer{
    [UIView animateWithDuration:.5 animations:^{
        CGRect frame = self.frame;
        frame.origin.x = CGRectGetWidth([UIScreen mainScreen].bounds) + STATUS_WIDTH;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [timer invalidate];
    }];
}

@end



@implementation YTStatusViewController{
    UILabel *_messageLabel;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, STATUS_WIDTH, CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))];
        _messageLabel.text = @"fuck you mather";
        _messageLabel.font = [UIFont systemFontOfSize:10];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        self.view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_messageLabel];
    }
    return self;
}

-(void)viewWillLayoutSubviews{
    self.view.frame = CGRectMake(0, 0, STATUS_WIDTH + 10, CGRectGetHeight(_messageLabel.frame));
    self.view.layer.cornerRadius = CGRectGetHeight(self.view.frame) / 2;
}

-(void)changeMessage:(NSString *)message{
    _messageLabel.text = message;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden{
    return false;
}
@end