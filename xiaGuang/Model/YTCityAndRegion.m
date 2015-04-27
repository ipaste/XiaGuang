//
//  YTCity.m
//  虾逛
//
//  Created by YunTop on 15/4/17.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTCityAndRegion.h"
@interface YTCity(){
    NSInteger _identify;
    NSString *_name;
    NSArray *_regions;
    FMDatabase *_db;
}

@end

@implementation YTCity
- (NSInteger)identify{
    return _identify;
}

- (NSString *)name{
    return _name;
}

- (NSArray *)regions{
    if (!_regions) {
        NSMutableArray *regions = [NSMutableArray new];
        FMResultSet *result = [_db executeQuery:@"SELECT * FROM Region WHERE city = ? and isExistence = 1 ORDER BY identify",[NSNumber numberWithInteger:_identify]];
        while ([result next]) {
            YTRegion *region = [[YTRegion alloc]initWithSqlResultSet:result];
            [regions addObject:region];
        }
        _regions = regions.copy;
        [regions removeAllObjects];
        regions = nil;
    }
    return _regions;
}

+ (instancetype)defaultCity{
    FMDatabase *db = [YTDataManager defaultDataManager].database;
    FMResultSet *result = [db executeQuery:@"SELECT * FROM City WHERE name = '深圳'"];
    [result next];
    return [[YTCity alloc]initWithSqlResultSet:result];
}

- (instancetype)initWithSqlResultSet:(FMResultSet *)result{
    self = [super init];
    if (self) {
        _identify = [result intForColumn:@"identify"];
        _name = [result stringForColumn:@"name"];
        if (!_db) {
            _db = [YTDataManager defaultDataManager].database;
        }
    }
    return self;
}

- (instancetype)initWithIdentify:(NSInteger)identify{
    _db = [YTDataManager defaultDataManager].database;
    FMResultSet *result = [_db executeQuery:@"SELECT * FROM City WHERE identify = ?",[NSNumber numberWithInteger:identify]];
    [result next];
    return [self initWithSqlResultSet:result];
}
@end

@interface YTRegion(){
    NSInteger _identify;
    NSString *_name;
    NSInteger _cityIdentify;
    YTCity *_city;
    FMDatabase *_db;
}

@end

@implementation YTRegion
- (NSInteger)identify{
    return _identify;
}

- (NSString *)name{
    return _name;
}

- (YTCity *)city {
    if (!_city) {
        FMResultSet *result = [_db executeQuery:@"SELECT * FROM City WHERE identify = ?",[NSNumber numberWithInteger:_cityIdentify]];
        _city = [[YTCity alloc]initWithSqlResultSet:result];
    }
    return _city;
}

- (instancetype)initWithIdentify:(NSInteger)identify{
    _db = [YTDataManager defaultDataManager].database;
    FMResultSet *result = [_db executeQuery:@"SELECT * FROM Region WHERE identify = ? ORDER BY identify",[NSNumber numberWithInteger:identify]];
    [result next];
    return [self initWithSqlResultSet:result];
}

- (instancetype)initWithSqlResultSet:(FMResultSet *)result{
    self = [super init];
    if (self) {
        _identify = [result intForColumn:@"identify"];
        _name = [result stringForColumn:@"name"];
        _cityIdentify = [result intForColumn:@"city"];
        if (!_db) {
            _db = [YTDataManager defaultDataManager].database;
        }
    }
    return self;
}

- (BOOL)isEqual:(YTRegion *)object{
    BOOL equalName = [object.name isEqualToString:self.name];
    BOOL equalIdentify = object.identify == self.identify ? true:false;
    return (equalIdentify && equalName);
}

@end
