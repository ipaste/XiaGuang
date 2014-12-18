//
//  YTLocalDoor.m
//  虾逛
//
//  Created by Yuan Tao on 12/15/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTLocalDoor.h"

@implementation YTLocalDoor{
    __weak NSString *_tmpDoorId;
    float _tmpLatitude;
    float _tmpLongtitude;
}

@synthesize identifier;
@synthesize coordinate;



-(id)initWithDBResultSet:(FMResultSet *)findResultSet{
    self = [super init];
    if(self){
        _tmpDoorId = [findResultSet stringForColumn:@"doorId"];
        _tmpLatitude = [findResultSet doubleForColumn:@"latitude"];
        _tmpLongtitude = [findResultSet doubleForColumn:@"longtitude"];
    }
    return self;
}

-(NSString *)identifier{
    return _tmpDoorId;
}

-(CLLocationCoordinate2D )coordinate{
    return CLLocationCoordinate2DMake(_tmpLatitude, _tmpLongtitude);
}



@end

