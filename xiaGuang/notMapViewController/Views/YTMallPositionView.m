//
//  YTMallPositionView.m
//  xiaGuang
//
//  Created by YunTop on 14/11/3.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTMallPositionView.h"

@implementation YTMallPositionView{
    
}

-(instancetype)initWithImage:(UIImage *)image phoneNumber:(NSInteger)number address:(NSString *)address{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    }
    return self;
}
@end
