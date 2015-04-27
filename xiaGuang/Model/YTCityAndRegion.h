//
//  YTCity.h
//  虾逛
//
//  Created by YunTop on 15/4/17.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTDataManager.h"

@interface YTCity : NSObject
@property (readonly ,nonatomic) NSInteger identify;
@property (readonly ,nonatomic) NSString *name;
@property (readonly ,nonatomic) NSArray *regions;

+ (instancetype)defaultCity;
- (instancetype)initWithSqlResultSet:(FMResultSet *)result;
- (instancetype)initWithIdentify:(NSInteger)identify;
@end


@interface YTRegion : NSObject
@property (readonly ,nonatomic) NSInteger identify;
@property (readonly ,nonatomic) NSString *name;
@property (readonly ,nonatomic) YTCity *city;

- (instancetype)initWithSqlResultSet:(FMResultSet *)result;
- (instancetype)initWithIdentify:(NSInteger)identify;
- (BOOL)isEqual:(YTRegion *)object;
@end