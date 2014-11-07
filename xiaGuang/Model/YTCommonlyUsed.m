//
//  YTCommonlyUsed.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-21.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTCommonlyUsed.h"

@implementation YTCommonlyUsed
+(NSArray *)commonlyUsed{
    YTCommonlyUsed *entrance = [[YTCommonlyUsed alloc]init];
    entrance.name = @"出入口";
    entrance.icon = [UIImage imageNamed:@"nav_ico_8"];
    
    YTCommonlyUsed *wc = [[YTCommonlyUsed alloc]init];
    wc.name = @"洗手间";
    wc.icon = [UIImage imageNamed:@"nav_ico_9"];
    
    YTCommonlyUsed *escalator = [[YTCommonlyUsed alloc]init];
    escalator.name = @"扶梯";
    escalator.icon = [UIImage imageNamed:@"nav_ico_10"];
    
    YTCommonlyUsed *elevator = [[YTCommonlyUsed alloc]init];
    elevator.name = @"电梯";
    elevator.icon = [UIImage imageNamed:@"nav_ico_11"];
/*
    YTCommonlyUsed *stopCar = [[YTCommonlyUsed alloc]init];
    stopCar.name = @"停车场";
    stopCar.icon = [UIImage imageNamed:@"nav_ico_12"];
*/
    YTCommonlyUsed *frontDesk = [[YTCommonlyUsed alloc]init];
    frontDesk.name = @"服务台";
    frontDesk.icon = [UIImage imageNamed:@"nav_ico_13"];
    return @[entrance,wc,escalator,elevator,frontDesk];
}
@end
