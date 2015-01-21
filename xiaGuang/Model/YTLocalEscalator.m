//
//  YTLocalEscalator.m
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTLocalEscalator.h"



@implementation YTLocalEscalator{
    NSString *_tmpEscalatorId;
    NSString *_tmpMajorAreaId;
    NSString *_tmpMinorAreaId;
    NSString *_tmpToMajorAreaId;
    float _tmpLatitude;
    float _tmpLongtitude;
    
    id<YTMajorArea> _tmpMajorArea;
    id<YTMinorArea> _tmpMinorArea;
    id<YTMajorArea> _tmpToMajorArea;
}

@synthesize majorArea;
@synthesize inMinorArea;
@synthesize coordinate;
@synthesize identifier;
@synthesize toMajorArea;

-(id)initWithDBResultSet:(FMResultSet *)findResultSet{
    if(findResultSet != nil){
        self = [super init];
        if(self){
            _tmpEscalatorId = [findResultSet stringForColumn:@"escalatorId"];
            _tmpLatitude = [findResultSet doubleForColumn:@"latitude"];
            _tmpLongtitude = [findResultSet doubleForColumn:@"longtitude"];
            _tmpMinorAreaId = [findResultSet stringForColumn:@"minorAreaId"];
            _tmpMajorAreaId = [findResultSet stringForColumn:@"majorAreaId"];
            _tmpToMajorAreaId = [findResultSet stringForColumn:@"toMajorAreaId"];
        }
    }
    return self;
    
}


-(id<YTMajorArea>)majorArea{
    if(_tmpMajorArea == nil){
        
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
        if([db open]){
            
            FMResultSet *result = [db executeQuery:@"select * from MajorArea where majorAreaId = ?",_tmpMajorAreaId];
            [result next];
            
            _tmpMajorArea = [[YTLocalMajorArea alloc] initWithDBResultSet:result];
        }
    }
    return _tmpMajorArea;
}

-(id<YTMinorArea>)inMinorArea{
    
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

-(CLLocationCoordinate2D )coordinate{
    return CLLocationCoordinate2DMake(_tmpLatitude, _tmpLongtitude);
}

-(NSString *)identifier{
    return _tmpEscalatorId;
}

-(YTPoi *)producePoi{
    YTEscalatorPoi *result = [[YTEscalatorPoi alloc]  initWithEscalator:self];
    return result;
}

-(NSString *)name{
    return @"扶梯";
}

-(NSString *)iconName{
    return @"nav_ico_10";
}

-(id<YTMajorArea>)toMajorArea{
    if(_tmpToMajorArea == nil){
        
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
        if([db open]){
            
            FMResultSet *result = [db executeQuery:@"select * from MajorArea where majorAreaId = ?",_tmpToMajorAreaId];
            [result next];
            
            _tmpToMajorArea = [[YTLocalMajorArea alloc] initWithDBResultSet:result];
        }
    }
    return _tmpToMajorArea;
}


@end
