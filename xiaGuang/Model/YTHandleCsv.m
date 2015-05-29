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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] 'Id'"];
    NSString *deleteKey = [fields filteredArrayUsingPredicate:predicate].firstObject;
    
    NSMutableArray *identifers = [NSMutableArray array];
    NSMutableArray *insertSqls = [NSMutableArray array];
    
    NSMutableDictionary *fieldType = [NSMutableDictionary dictionary];
    
    FMResultSet *schemas = [database getTableSchema:tableName];
    
    while ([schemas next]) {
        NSPredicate *schemaKey = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@",[schemas stringForColumn:@"name"],[schemas stringForColumn:@"name"]];
        NSArray *tempFields = [fields filteredArrayUsingPredicate:schemaKey];
        if (tempFields.count > 0) {
            NSString *field = tempFields.firstObject;
            [fieldType setObject:[schemas stringForColumn:@"type"] forKey:field];
        }
    }

    
    for (NSString *data in datas){
        if ([data isEqualToString:@""]){
            continue;
        }
        NSArray *contens = [data componentsSeparatedByString:@","];
        
        id value = nil;
        
        if (deleteKey != nil) {
            value = contens[[fields indexOfObject:deleteKey]];
            if (![identifers containsObject:value]) {
                [identifers addObject:value];
            }
            
        }
        
        NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT INTO %@%@ VALUES(",tableName,fields];
        for (int index = 0; index < fields.count; index++) {
            NSString *field = fields[index];
            NSString *value = contens[index];
            
            [field stringByReplacingOccurrencesOfString:@" " withString:@""];
            [value stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([field isEqualToString:@""] || [field isEqualToString:@""]) {
                continue;
            }
            
            NSString *type = fieldType[field];
            
            id result = nil;
            if ([type isEqualToString:@"REAL"]) {
                result = [NSNumber numberWithDouble:[value doubleValue]];
            }else if ([type isEqualToString:@"TEXT"]){
                result = [NSString stringWithFormat:@"\"%@\"",value];
            }else if ([type isEqualToString:@"INTEGER"]){
                result = [NSNumber numberWithInt:[value intValue]];
            }else{
                result = @0;
                NSLog(@"找不到该字段所属的类型：%@",field);
            }
            
            [sql appendFormat:@"%@,",result];
        }
        [sql replaceCharactersInRange:NSMakeRange(sql.length - 1, 1) withString:@")"];
        [insertSqls addObject:sql];
    }
    
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ IN %@ ",tableName,deleteKey,identifers];
    [database executeUpdate:deleteSQL];
    

    for (NSString *sql in insertSqls) {
        [database executeUpdate:sql];
    }

    NSLog(@"%@表插入成功",tableName);
}
@end
