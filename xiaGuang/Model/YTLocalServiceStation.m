//
//  YTLocalServiceStation.m
//  xiaGuang
//
//  Created by Yuan Tao on 11/7/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTLocalServiceStation.h"



@implementation YTLocalServiceStation{
    NSString *_tmpServiceStationId;
    NSString *_tmpMajorAreaId;
    NSString *_tmpMinorAreaId;
    float _tmpLatitude;
    float _tmpLongtitude;
    
    id<YTMajorArea> _tmpMajorArea;
    id<YTMinorArea> _tmpMinorArea;
}

@synthesize majorArea;
@synthesize inMinorArea;
@synthesize coordinate;
@synthesize identifier;

-(id)initWithDBResultSet:(FMResultSet *)findResultSet{
    if(findResultSet != nil){
        self = [super init];
        if(self){
            _tmpServiceStationId = [findResultSet stringForColumn:@"serviceStationId"];
            _tmpLatitude = [findResultSet doubleForColumn:@"latitude"];
            _tmpLongtitude = [findResultSet doubleForColumn:@"longtitude"];
            _tmpMinorAreaId = [findResultSet stringForColumn:@"minorAreaId"];
            _tmpMajorAreaId = [findResultSet stringForColumn:@"majorAreaId"];
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
    return _tmpServiceStationId;
}

-(YTPoi *)producePoi{
    YTServiceStationPoi *result = [[YTServiceStationPoi alloc]  initWithServiceStation:self];
    return result;
}

-(NSString *)name{
    return @"服务台";
}

-(NSString *)iconName{
    return @"nav_ico_13";
}


@end