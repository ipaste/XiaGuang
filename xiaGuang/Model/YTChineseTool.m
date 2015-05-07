//
//  YTChineseTool.m
//  虾逛
//
//  Created by YunTop on 15/2/12.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTChineseTool.h"

@implementation YTChineseTool
+ (BOOL) isIncludeChineseInString:(NSString *)str {
    for (int i=0; i<str.length; i++) {
        unichar ch = [str characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff) {
            return true;
        }
    }
    return false;
}

@end
