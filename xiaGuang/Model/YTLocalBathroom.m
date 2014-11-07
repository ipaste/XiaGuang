//
//  YTLocalBathroom.m
//  HighGuang
//
//  Created by Yuan Tao on 10/22/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTLocalBathroom.h"

@implementation YTLocalBathroom{
    NSString *_tmpBathroomId;
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
@synthesize name;
@synthesize iconName;


-(id)initWithDBResultSet:(FMResultSet *)findResultSet{
    if(findResultSet != nil){
        self = [super init];
        if(self){
            _tmpBathroomId = [findResultSet stringForColumn:@"bathroomId"];
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
        
        FMDatabase *db = [YTDBManager sharedManager].db;
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
        
        FMDatabase *db = [YTDBManager sharedManager].db;
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
    return _tmpBathroomId;
}

-(YTPoi *)producePoi{
    YTBathroomPoi *result = [[YTBathroomPoi alloc]  initWithBathroom:self];
    return result;
}

-(NSString *)name{
    return @"洗手间";
}

-(NSString *)iconName{
    return @"nav_ico_9";
}
@end
