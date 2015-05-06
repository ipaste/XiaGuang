//
//  YTHandleCsv.m
//  虾逛
//
//  Created by YunTop on 15/5/1.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTHandleCsv.h"

@implementation YTHandleCsv
+ (void)saveData:(FMDatabase *)database tableName:(NSString *)tableName fields:(NSArray *)fields datas:(NSArray *)datas{
    [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:@""]) {
            return ;
        }
        
        NSMutableString *sql = nil;
        
        BOOL isUpdata = false;
        
        NSArray *contents = [obj componentsSeparatedByString:@","];
        
        NSString *identify = [fields containsObject:@"uniId"] == true ? @"uniId":fields[0];
        
        NSInteger index = [fields containsObject:@"uniId"] == true ? [fields indexOfObject:identify]:0;
        
        NSString *tmpSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %@",tableName,identify,contents[index]];
        
        FMResultSet *result = [database executeQuery:tmpSql];
        if ([result next]) {
            //更新数据
            isUpdata = true;
            sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",tableName];
        }else{
            //插入数据
            sql = [NSMutableString stringWithFormat:@"INSERT INTO %@%@ VALUES(",tableName,fields];
        }
    
            FMResultSet *tmpResult = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",tableName]];
            [tmpResult next];
            for (NSInteger index = 0 ;index < contents.count;index++) {
                NSString *key = fields[index];
                id value = contents[index];
                id object = [tmpResult objectForColumnName:key];
                if ([object isKindOfClass:[NSNumber class]]) {
                    value = [NSNumber numberWithFloat:[value floatValue]];
                }else if ([object isKindOfClass:[NSString class]]){
                    value = [NSString stringWithFormat:@"\"%@\"",value];
                }
                if (isUpdata) {
                    [sql appendFormat:@"%@ = %@,",key,value];
                }else{
                    [sql appendFormat:@"%@,",value];
                }
            }
            [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
            if (isUpdata){
                [sql appendFormat:@" WHERE %@ = %@",identify,contents[index]];
            }else{
                [sql appendFormat:@")"];
            }
            
        [database executeUpdate:sql];
    }];
    
}
@end
