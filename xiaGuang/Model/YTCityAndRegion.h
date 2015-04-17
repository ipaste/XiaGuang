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
@property (readonly ,nonatomic) NSString *identify;
@property (readonly ,nonatomic) NSString *name;
@property (readonly ,nonatomic) NSArray *regions;

- (instancetype)initWithSqlResultSet:(FMResultSet *)result;
- (instancetype)initWithCloudObject:(AVObject *)object;
@end


@interface YTRegion : NSObject
@property (readonly ,nonatomic) NSString *identify;
@property (readonly ,nonatomic) NSString *name;
@property (readonly ,nonatomic) YTCity *city;

- (instancetype)initWithSqlResultSet:(FMResultSet *)result;
- (instancetype)initWithCloudObject:(AVObject *)object;
@end