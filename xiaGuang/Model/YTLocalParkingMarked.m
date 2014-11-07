//
//  YTLocalParking.m
//  xiaGuang
//
//  Created by YunTop on 14/11/3.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTLocalParkingMarked.h"

@implementation YTLocalParkingMarked{
    YTUserDefaults *_userDefaults;
    FMDatabase *_dateBase;
    YTParkingMarkPoi *_tmpParkingPOi;
}
+(instancetype)standardParking{
    static YTLocalParkingMarked *localParking;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localParking = [[YTLocalParkingMarked alloc]init];
    });
    
    return localParking;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _userDefaults = [YTUserDefaults standardUserDefaults];
        _dateBase = [YTDBManager sharedManager].db;
    }
    return self;
}
-(BOOL)whetherMark{
    return [_userDefaults existenceOfTheKey:PARKING_CLASS_KEY];
}

-(NSString *)name{
    return [[_userDefaults dictionaryWithKey:PARKING_CLASS_KEY] valueForKey:PARKING_NAME_KEY];
}

-(CLLocationCoordinate2D)coordinate{
    return  [_userDefaults coord];
}

-(id<YTMinorArea>)inMinorArea{
    NSString *minorIdentifier = [[_userDefaults dictionaryWithKey:PARKING_CLASS_KEY] valueForKey:PARKING_MINOR_KEY];
    id<YTMinorArea> tmpMinorArea = nil;
    if ([_dateBase open]) {
        FMResultSet *result = [_dateBase executeQuery:@"select * from MinorArea where minorAreaId = ?",minorIdentifier];
        [result next];
        
        tmpMinorArea = [[YTLocalMinorArea alloc] initWithDBResultSet:result];
    }
    return tmpMinorArea;
}

-(id<YTMajorArea>)majorArea{
    NSString *majorAreaIdentifier = [[_userDefaults dictionaryWithKey:PARKING_CLASS_KEY] valueForKey:PARKING_MAJOR_KEY];
    id<YTMajorArea> tmpMajorArea = nil;
    if ([_dateBase open]) {
        FMResultSet *result = [_dateBase executeQuery:@"select * from MajorArea where majorAreaId = ?",majorAreaIdentifier];
        [result next];
        
        tmpMajorArea = [[YTLocalMajorArea alloc] initWithDBResultSet:result];
    }
    return tmpMajorArea;
}

-(NSTimeInterval)parkingDuration{
    NSDate *parkingDate = [[_userDefaults dictionaryWithKey:PARKING_CLASS_KEY] valueForKey:PARKING_TIME_KEY];
    NSTimeInterval systemTime = [[NSTimeZone systemTimeZone] secondsFromGMT];
    NSTimeInterval parkingTime = [parkingDate timeIntervalSinceNow];
    if (parkingDate == nil) return 0;
    return systemTime - parkingTime;
}
-(void)saveParkingInfoWithMinorArea:(id<YTMinorArea>)minorArea{
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
    NSDate *nowDate = [NSDate dateWithTimeIntervalSinceNow:timeZoneOffset];
    [_userDefaults setCoord:[minorArea coordinate]];
    NSDictionary *tmpDict = @{PARKING_MINOR_KEY:[minorArea identifier],PARKING_MAJOR_KEY:[[minorArea majorArea] identifier],PARKING_NAME_KEY:@"停车场",PARKING_TIME_KEY:nowDate};
    [_userDefaults setDictionary:tmpDict forKey:PARKING_CLASS_KEY];
    
}
-(void)clearParkingInfo{
    [_userDefaults removeCoord];
    [_userDefaults removeDictionaryForKey:PARKING_CLASS_KEY];
    [_tmpParkingPOi removePoiLayer];
    _tmpParkingPOi = nil;
}

-(YTPoi *)producePoi{

    if ([self whetherMark] && _tmpParkingPOi == nil) {
        _tmpParkingPOi = [[YTParkingMarkPoi alloc]initWithParkingMarkCoordinat:[self coordinate]];
    }
    return _tmpParkingPOi;
}
@end
