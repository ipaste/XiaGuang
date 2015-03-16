//
//  YTMajorAreaInstance.m
//  虾逛
//
//  Created by Yuan Tao on 1/22/15.
//  Copyright (c) 2015 YunTop. All rights reserved.
//

#import "YTMajorAreaDict.h"

@implementation YTMajorAreaDict
{
    NSMutableDictionary *_idToArea;
}

-(id)init{
    self = [super init];
    if(self){
        _idToArea = [NSMutableDictionary new];
    }
    return self;
}

+(id)sharedInstance{
    static YTMajorAreaDict *sharedInstance = nil;
    if (!sharedInstance)
    {
        
        sharedInstance = [[YTMajorAreaDict alloc] init];
    }
    return sharedInstance;
}


-(id<YTMajorArea>)getMajorAreaFromId:(NSString *)identifier{
    
    id<YTMajorArea> resultArea = [_idToArea objectForKey:identifier];
    
    if(resultArea == nil){
        
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
        if([db open]){
            
            FMResultSet *result = [db executeQuery:@"select * from MajorArea where majorAreaId = ?",identifier];
            [result next];
            
            resultArea = [[YTLocalMajorArea alloc] initWithDBResultSet:result];
        }
        
        [_idToArea setObject:resultArea forKey:identifier];
        
    }
    
    return resultArea;
    
}

@end
