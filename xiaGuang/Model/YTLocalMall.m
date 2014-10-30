//
//  YTLocalMall.m
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTLocalMall.h"

@implementation YTLocalMall{
    NSString *_tmpMallId;
    NSString *_tmpMallName;
    NSMutableArray *_tmpBlocks;
    NSMutableArray *_tmpMerchantInstance;
}

@synthesize mallName;
@synthesize identifier;
@synthesize blocks;
@synthesize merchantLocations;

-(id)initWithDBResultSet:(FMResultSet *)findResultSet{
    if(findResultSet != nil){
        self = [super init];
        if(self){
            _tmpMallId = [findResultSet stringForColumn:@"mallId"];
            _tmpMallName = [findResultSet stringForColumn:@"mallName"];
        }
    }
    return self;
    
}

-(NSString *)mallName{
    return _tmpMallName;
}

-(NSString *)identifier{
    return _tmpMallId;
}

-(NSArray *)blocks{
    
    if(_tmpBlocks == nil){
        
        FMDatabase *db = [YTDBManager sharedManager];
        FMResultSet *resultSet = [db executeQuery:@"select * from Block where mallId = ?",_tmpMallId];
        
        _tmpBlocks = [[NSMutableArray alloc] init];
        
        while ([resultSet next]) {
            YTLocalBlock *tmp = [[YTLocalBlock alloc] initWithDBResultSet:resultSet];
            [_tmpBlocks addObject:tmp];
        }
        
    }
    
    return _tmpBlocks;
}

-(NSArray *)merchantLocations{
    
    if(_tmpMerchantInstance == nil){
        
        FMDatabase *db = [YTDBManager sharedManager];
        FMResultSet *resultSet = [db executeQuery:@"select * from MerchantInstance where mallId = ?",_tmpMallId];
        
        _tmpMerchantInstance = [[NSMutableArray alloc] init];
        
        while ([resultSet next]) {
            YTLocalMerchantInstance *tmp = [[YTLocalMerchantInstance alloc] initWithDBResultSet:resultSet];
            [_tmpMerchantInstance addObject:tmp];
        }
        
    }
    
    return _tmpMerchantInstance;
}

@end
