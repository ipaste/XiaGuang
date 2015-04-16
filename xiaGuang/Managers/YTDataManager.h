//
//  YTDataManager.h
//  虾逛
//
//  Created by YunTop on 15/4/16.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCFileManager.h"
#import "Reachability.h"
#import "FMDB.h"

@interface YTDataManager : NSObject

@property (readonly ,nonatomic) FMDatabase *database;

+ (instancetype)defaultDataManager;
@end
