//
//  YTCity.m
//  虾逛
//
//  Created by YunTop on 15/4/17.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTCityAndRegion.h"
@interface YTCity(){
    NSString *_identify;
    NSString *_name;
    NSArray *_regions;
    FMDatabase *_db;
}

@end

@implementation YTCity
- (NSString *)identify{
    return _identify;
}

- (NSString *)name{
    return _name;
}

- (NSArray *)regions{
    if (!_regions) {
        NSMutableArray *regions = [NSMutableArray new];
        FMResultSet *result = [_db executeQuery:@"SELECT * FROM Region WHERE city = ?",_identify];
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

- (instancetype)initWithSqlResultSet:(FMResultSet *)result{
    self = [super init];
    if (self) {
        _identify = [result stringForColumn:@"identify"];
        _name = [result stringForColumn:@"name"];
        if (!_db) {
            _db = [YTDataManager defaultDataManager].database;
        }
    }
    return self;
}

- (instancetype)initWithCloudObject:(AVObject *)object{
    _db = [YTDataManager defaultDataManager].database;
    FMResultSet *result = [_db executeQuery:@"SELCT * FROM City WHERE identify = ?",object.objectId];
    return [self initWithSqlResultSet:result];
}
@end

@interface YTRegion(){
    NSString *_identify;
    NSString *_name;
    NSString *_cityIdentify;
    YTCity *_city;
    FMDatabase *_db;
}

@end

@implementation YTRegion
- (NSString *)identify{
    return _identify;
}

- (NSString *)name{
    return _name;
}
- (YTCity *)city {
    if (!_city) {
        FMResultSet *result = [_db executeQuery:@"SELECT * FROM City WHERE identify = ?",_cityIdentify];
        _city = [[YTCity alloc]initWithSqlResultSet:result];
    }
    return _city;
}

- (instancetype)initWithCloudObject:(AVObject *)object{
    _db = [YTDataManager defaultDataManager].database;
    FMResultSet *result = [_db executeQuery:@"SELCT * FROM Region WHERE identify = ?",object.objectId];
    return [self initWithSqlResultSet:result];
}

-(instancetype)initWithSqlResultSet:(FMResultSet *)result{
    self = [super init];
    if (self) {
        _identify = [result stringForColumn:@"identify"];
        _name = [result stringForColumn:@"name"];
        _cityIdentify = [result stringForColumn:@"city"];
        if (!_db) {
            _db = [YTDataManager defaultDataManager].database;
        }
    }
    return self;
}

@end
