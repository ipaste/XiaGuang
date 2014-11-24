//
//  YTLocalFloor.m
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTLocalFloor.h"

@implementation YTLocalFloor{
    NSString *_tmpFloorId;
    NSString *_tmpBlockId;
    int _tmpFloorWeight;
    NSString *_tmpFloorName;
    
    NSMutableArray *_tmpMajorAreas;
    id<YTBlock> _tmpBlock;
    
}

@synthesize majorAreas;
@synthesize block;
@synthesize floorName;
@synthesize identifier;

-(id)initWithDBResultSet:(FMResultSet *)findResultSet{
    if(findResultSet != nil){
        self = [super init];
        if(self){
            _tmpFloorId = [findResultSet stringForColumn:@"floorId"];
            _tmpBlockId = [findResultSet stringForColumn:@"blockId"];
            _tmpFloorWeight = [findResultSet intForColumn:@"weight"];
            _tmpFloorName = [findResultSet stringForColumn:@"floorName"];
            
        }
    }
    return self;
    
}


-(NSString *)identifier{
    return _tmpFloorId;
}

-(NSString *)floorName{
    return _tmpFloorName;
}

-(NSNumber *)floorWeight{
    return [NSNumber numberWithInteger:_tmpFloorWeight];
}

-(id<YTBlock>)block{
    if(_tmpBlock == nil){
        
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
        if([db open]){
            
            FMResultSet *result = [db executeQuery:@"select * from Block where blockId = ?",_tmpBlockId];
            [result next];
            
            _tmpBlock = [[YTLocalBlock alloc] initWithDBResultSet:result];
        }
    }
    return _tmpBlock;
}

-(NSArray *)majorAreas{
    if(_tmpMajorAreas == nil){
        
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
        FMResultSet *resultSet = [db executeQuery:@"select * from MajorArea where floorId = ?",_tmpFloorId];
        
        _tmpMajorAreas = [[NSMutableArray alloc] init];
        
        while ([resultSet next]) {
            YTLocalMajorArea *tmp = [[YTLocalMajorArea alloc] initWithDBResultSet:resultSet];
            [_tmpMajorAreas addObject:tmp];
        }
        
    }
    
    return _tmpMajorAreas;
}


@end
