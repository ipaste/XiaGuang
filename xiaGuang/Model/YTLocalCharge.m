//
//  YTLocalCharge.m
//  xiaGuang
//
//  Created by YunTop on 14/11/7.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTLocalCharge.h"

@implementation YTLocalCharge{
    NSInteger _tmpP;
    NSInteger _tmpK;
    NSInteger _tmpA;
    NSInteger _tmpMax;
    NSInteger _freeTime;
}

-(id)initWithMallID:(NSString *)mallID{
    self = [super init];
    if(self){
            FMDatabase *db = [YTDataManager defaultDataManager].database;
            [db open];
            FMResultSet *result = [db executeQuery:@"select * from ChargeEngine where mallId = ?",mallID];
            [result next];
            self.Max = [result intForColumn:@"max"];
            self.A = [result intForColumn:@"a"];
            self.P = [result intForColumn:@"p"];
            self.K = [result intForColumn:@"k"];
            self.freeTime = [result intForColumn:@"freeTime"];
    }
    return self;
    
}

@end
