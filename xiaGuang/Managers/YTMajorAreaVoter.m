//
//  YTMajorAreaVoter.m
//  虾逛
//
//  Created by Yuan Tao on 11/19/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTMajorAreaVoter.h"

@implementation YTMajorAreaVoter

+(NSString *)shouldSwitchToMajorAreaId:(NSArray *)beacons{
    
    NSArray *readbeacons = beacons;
    int analyzeTotal = MIN(10,readbeacons.count);
    
    NSMutableDictionary *scoreboard = [[NSMutableDictionary alloc] init];
    ESTBeacon *tmpBeacon;
    id<YTMajorArea> tmpMajorArea;
    NSNumber *total;
    double tmpDist;
    for(int i = 0; i<analyzeTotal; i++){
        
        tmpBeacon = readbeacons[i];
        
        NSLog(@"beacon no %d: major:%@ minor:%@ distance:%f from majorArea:%@",i,tmpBeacon.major,tmpBeacon.minor, [tmpBeacon.distance doubleValue], [[self getMajorArea:tmpBeacon] identifier]);
        
        if([tmpBeacon.distance doubleValue]<0){
            continue;
        }
        tmpMajorArea = [self getMajorArea:tmpBeacon];
        total = [scoreboard objectForKey:[tmpMajorArea identifier]];
        if(total == nil){
            tmpDist = [tmpBeacon.distance doubleValue];
            double score = 1.0 / (tmpDist*tmpDist);
            [scoreboard setObject:[NSNumber numberWithDouble:score] forKey:[tmpMajorArea identifier]];
        }
        else{
            tmpDist = [tmpBeacon.distance doubleValue];
            double score = 1.0 / (tmpDist*tmpDist);
            score = [total doubleValue] + score;
            [scoreboard setObject:[NSNumber numberWithDouble:score] forKey:[tmpMajorArea identifier]];
        }
    }
    
    __block NSString *strongestMajorAreaId;
    __block double strongScore = -INFINITY;
    
    [scoreboard enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        double curScore =[(NSNumber *)obj doubleValue];
        NSLog(@"id:%@ score:%f",key, curScore);
        if(curScore > strongScore){
            strongScore = curScore;
            strongestMajorAreaId = key;
        }
        
    }];
    if(strongestMajorAreaId == nil){
        NSLog(@"oops");
    }
    NSLog(@"strongestMajorAreaId is %@",strongestMajorAreaId);
    return strongestMajorAreaId;

}

+(id<YTMajorArea>)getMajorArea:(ESTBeacon *)beacon{
    
    FMDatabase *db = [YTStaticResourceManager sharedManager].db;
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from Beacon where major = ? and minor = ?",[beacon.major stringValue],[beacon.minor stringValue]];
    [result next];
    YTLocalBeacon *localBeacon = [[YTLocalBeacon alloc] initWithDBResultSet:result];
    
    YTLocalMajorArea * majorArea = [[localBeacon minorArea] majorArea];
    return majorArea;
}



@end
