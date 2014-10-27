//
//  YTDBManager.m
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTDBManager.h"

@implementation YTDBManager

+(id)sharedManager{
    static FMDatabase *dbInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"highGuangDB" ofType:@""];
        dbInstance = [[FMDatabase alloc] initWithPath:path];
    });
    return dbInstance;
}

@end
