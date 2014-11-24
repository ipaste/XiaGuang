//
//  YTLocalBeacon.m
//  HighGuang
//
//  Created by Yuan Tao on 9/1/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTLocalBeacon.h"

@implementation YTLocalBeacon{
    int _tmpMinor;
    int _tmpMajor;
    NSString *_tmpBeaconId;
    NSString *_tmpMinorAreaId;
    id<YTMinorArea> _tmpMinorArea;
}

@synthesize minor;
@synthesize major;
@synthesize minorArea;
@synthesize identifier;

-(id)initWithDBResultSet:(FMResultSet *)findResultSet{
    if(findResultSet != nil){
        self = [super init];
        if(self){
            _tmpMinor = [findResultSet intForColumn:@"minor"];
            _tmpMajor = [findResultSet intForColumn:@"major"];
            _tmpBeaconId = [findResultSet stringForColumn:@"beaconId"];
            _tmpMinorAreaId = [findResultSet stringForColumn:@"minorAreaId"];
        }
    }
    return self;
    
}

-(NSNumber *)minor{
    return [NSNumber numberWithInt:_tmpMinor];
}

-(NSNumber *)major{
    return [NSNumber numberWithInt:_tmpMajor];
}

-(NSString *)identifier{
    return _tmpBeaconId;
}

-(id<YTMinorArea>)minorArea{
    
    if(_tmpMinorArea == nil){
    
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
        if([db open]){
        
            FMResultSet *result = [db executeQuery:@"select * from MinorArea where minorAreaId = ?",_tmpMinorAreaId];
            [result next];
        
            _tmpMinorArea = [[YTLocalMinorArea alloc] initWithDBResultSet:result];
        }
    }
    return _tmpMinorArea;
}

@end
