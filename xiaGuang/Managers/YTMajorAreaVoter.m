//
//  YTMajorAreaVoter.m
//  虾逛
//
//  Created by Yuan Tao on 11/19/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTMajorAreaVoter.h"

@implementation YTMajorAreaVoter{
    NSMutableDictionary *_majorAreaDict;
    NSMutableDictionary *_beaconDict;
}

+(id)sharedInstance{
    static YTMajorAreaVoter *sharedInstance = nil;
    if (!sharedInstance)
    {
        
        sharedInstance = [[YTMajorAreaVoter alloc] init];
    }
    return sharedInstance;
}

-(id)init{
    self = [super init];
    if(self){
        
        _majorAreaDict = [NSMutableDictionary new];
        _beaconDict = [NSMutableDictionary new];
        
    }
    return self;
}

-(NSString *)shouldSwitchToMajorAreaId:(NSArray *)objects{
    
    NSArray *readbeacons = objects;
    int analyzeTotal = MIN(10,readbeacons.count);
    
    NSMutableDictionary *scoreboard = [[NSMutableDictionary alloc] init];
    ESTBeacon *tmpBeacon;
    id<YTMajorArea> tmpMajorArea;
    NSNumber *total;
    double tmpDist;
    NSNumber *distance;
    for(int i = 0; i<analyzeTotal; i++){
        
        tmpBeacon = readbeacons[i][@"Beacon"];
        distance = readbeacons[i][@"distance"];
        if([distance doubleValue]<0){
            continue;
        }
        tmpMajorArea = [self getMajorArea:tmpBeacon];
        total = [scoreboard objectForKey:[tmpMajorArea identifier]];
        if(total == nil){
            tmpDist = [distance doubleValue];
            double score = 1.0 / (tmpDist*tmpDist);
            [scoreboard setObject:[NSNumber numberWithDouble:score] forKey:[tmpMajorArea identifier]];
        }
        else{
            tmpDist = [distance doubleValue];
            double score = 1.0 / (tmpDist*tmpDist);
            score = [total doubleValue] + score;
            [scoreboard setObject:[NSNumber numberWithDouble:score] forKey:[tmpMajorArea identifier]];
        }
    }
    
    __block NSString *strongestMajorAreaId;
    __block double strongScore = -INFINITY;
    
    [scoreboard enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        double curScore =[(NSNumber *)obj doubleValue];
    
        if(curScore > strongScore){
            strongScore = curScore;
            strongestMajorAreaId = key;
        }
        
    }];
    if(strongestMajorAreaId == nil){
        NSLog(@"oops");
    }
    return strongestMajorAreaId;

}

-(id<YTMajorArea>)getMajorArea:(ESTBeacon *)beacon{
    
    NSString *key = [self keyFromBeacon:beacon];
    YTLocalMajorArea *resultArea = [_majorAreaDict objectForKey:key];
    
    if(resultArea != nil){
        return resultArea;
    }
    
    FMDatabase *db = [YTStaticResourceManager sharedManager].db;
    [db open];
    
    FMResultSet *result = [db executeQuery:@"select * from Beacon where major = ? and minor = ?",[beacon.major stringValue],[beacon.minor stringValue]];
    [result next];
    YTLocalBeacon *localBeacon = [[YTLocalBeacon alloc] initWithDBResultSet:result];
    
    YTLocalMajorArea * majorArea = [[localBeacon minorArea] majorArea];
    [_majorAreaDict setObject:majorArea forKey:key];
    return majorArea;
}


-(NSString *)keyFromBeacon:(ESTBeacon *)beacon{
    return [NSString stringWithFormat:@"%@-%@",beacon.major,beacon.minor];
}



@end
