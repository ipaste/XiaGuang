//
//  YTLocalCharge.h
//  xiaGuang
//
//  Created by YunTop on 14/11/7.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"
#import "YTDataManager.h"

@interface YTLocalCharge : NSObject
@property (assign,nonatomic) NSInteger A;
@property (assign,nonatomic) NSInteger K;
@property (assign,nonatomic) NSInteger P;
@property (assign,nonatomic) NSInteger Max;
@property (assign,nonatomic) NSInteger freeTime;
-(id)initWithMallID:(NSString *)mallID;
@end
