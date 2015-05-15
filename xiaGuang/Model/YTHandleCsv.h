//
//  YTHandleCsv.h
//  虾逛
//
//  Created by YunTop on 15/5/1.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTDataManager.h"
@interface YTHandleCsv : NSObject
+ (void)saveData:(FMDatabase *)database tableName:(NSString *)tableName fields:(NSArray *)fields datas:(NSArray *)datas;
@end
