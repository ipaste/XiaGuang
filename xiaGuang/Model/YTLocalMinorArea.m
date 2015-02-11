//
//  YTLocalMinorArea.m
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTLocalMinorArea.h"
#import "YTMinorAreaPoi.h"
@implementation YTLocalMinorArea{
    NSString *_tmpMinorAreaName;
    NSString *_tmpMajorAreaId;
    NSString *_tmpMinorAreaId;
    double _tmpLatitude;
    double _tmpLongtitude;
    NSMutableArray *_tmpBeacons;
    id<YTMajorArea> _tmpMajorArea;
}

@synthesize minorAreaName;
@synthesize majorArea;
@synthesize identifier;
@synthesize beacons;
@synthesize coordinate;

-(id)initWithDBResultSet:(FMResultSet *)findResultSet{
    if(findResultSet != nil){
        self = [super init];
        if(self){
            _tmpMinorAreaName = [findResultSet stringForColumn:@"minorAreaName"];
            _tmpMinorAreaId = [findResultSet stringForColumn:@"minorAreaId"];
            _tmpMajorAreaId = [findResultSet stringForColumn:@"majorAreaId"];
            _tmpLatitude = [findResultSet doubleForColumn:@"latitude"];
            _tmpLongtitude = [findResultSet doubleForColumn:@"longtitude"];
        }
    }
    return self;
    
}

-(NSString *)minorAreaName{
    return _tmpMinorAreaName;
}

-(NSString *)identifier{
    return _tmpMinorAreaId;
}

-(CLLocationCoordinate2D )coordinate{
    return CLLocationCoordinate2DMake(_tmpLatitude, _tmpLongtitude);
}

-(NSArray *)beacons{
    if(_tmpBeacons == nil){
        
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
        FMResultSet *resultSet = [db executeQuery:@"select * from Beacon where minorAreaId = ?",_tmpMinorAreaId];
        
        _tmpBeacons = [[NSMutableArray alloc] init];
        
        while ([resultSet next]) {
            YTLocalBeacon *tmp = [[YTLocalBeacon alloc] initWithDBResultSet:resultSet];
            [_tmpBeacons addObject:tmp];
        }
        
    }
    
    return _tmpBeacons;
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

-(YTPoi *)producePoi{
    YTMinorAreaPoi *result = [[YTMinorAreaPoi alloc] initWithMinorArea:self];
    return result;
}
@end
