//
//  YTLocalBlock.m
//  HighGuang
//
//  Created by Yuan Tao on 10/10/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTLocalBlock.h"

@implementation YTLocalBlock{
    NSString *_tmpBlockId;
    NSString *_tmpBlockName;
    NSString *_tmpMallId;
    
    id<YTMall> _tmpMall;
    
    NSMutableArray *_tmpFloors;
}

@synthesize blockName;
@synthesize mall;
@synthesize floors;


-(id)initWithDBResultSet:(FMResultSet *)findResultSet{
    if(findResultSet != nil){
        self = [super init];
        if(self){
            _tmpMallId = [findResultSet stringForColumn:@"mallId"];
            _tmpBlockName = [findResultSet stringForColumn:@"blockName"];
            _tmpBlockId = [findResultSet stringForColumn:@"blockId"];
        }
    }
    return self;
    
}


-(NSString *)blockName{
    return _tmpBlockName;
}


-(id<YTMall>)mall{
    if(_tmpMall == nil){
        
        FMDatabase *db = [YTDataManager defaultDataManager].database;
        if([db open]){
            
            FMResultSet *result = [db executeQuery:@"select * from Mall where mallId = ?",_tmpMallId];
            [result next];
            
            _tmpMall = [[YTLocalMall alloc] initWithDBResultSet:result];
        }
    }
    return _tmpMall;
}

-(NSArray *)floors{
    if(_tmpFloors == nil){
        
        FMDatabase *db = [YTDataManager defaultDataManager].database;
        FMResultSet *resultSet = [db executeQuery:@"select * from Floor where blockId = ?",_tmpBlockId];
        
        _tmpFloors = [[NSMutableArray alloc] init];
        
        while ([resultSet next]) {
            YTLocalFloor *tmp = [[YTLocalFloor alloc] initWithDBResultSet:resultSet];
            [_tmpFloors addObject:tmp];
        }
        
        [_tmpFloors sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([(YTLocalFloor *)obj1 queue]  > [(YTLocalFloor *)obj2 queue] ) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }];
        
    }
    
    return _tmpFloors;
}

@end
