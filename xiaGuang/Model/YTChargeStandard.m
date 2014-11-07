//
//  YTChargeStandard.m
//  xiaGuang
//
//  Created by YunTop on 14/11/7.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTChargeStandard.h"

@implementation YTChargeStandard

//a + ( x - k) * p

+(int)chargeStandardForTime:(int)time p:(int)p k:(int)k a:(int)a maxMoney:(int)maxMoney{
    int charge = a + (time - k) * p;
    return charge > maxMoney ? maxMoney:charge;
}
@end
