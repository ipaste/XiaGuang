//
//  YTMallDict.m
//  虾逛
//
//  Created by YunTop on 15/3/13.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTMallDict.h"
@implementation YTMallDict{
    NSArray *_localMalls;
    NSArray *_cloudMalls;
    NSArray *_localMallIds;
    FMDatabase *_db;
}


+ (instancetype)sharedInstance{
    static YTMallDict *mallDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mallDict = [[YTMallDict alloc]init];
    });
    return mallDict;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _db = [YTDataManager defaultDataManager].database;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getAllLocalMallWithCallBack:nil];
            [self getAllCloudMallWithCallBack:nil];
        });
    }
    return self;
}


- (BOOL)loadFinishes{
    if (_localMalls != nil && _cloudMalls != nil) {
        return true;
    }
    return false;
}

- (NSArray *)localMallIds{
    if (!_localMallIds) {
        NSMutableArray *malls = [NSMutableArray new];
        FMResultSet *result = [_db executeQuery:@"SELECT mallId FROM Mall"];
        while ([result next]) {
            [malls addObject:[result stringForColumn:@"mallId"]];
        }
        _localMallIds = malls.copy;
        [malls removeAllObjects];
        malls = nil;
    }
    return _localMallIds;
}

- (void)getAllCloudMallWithCallBack:(void (^)(NSArray *malls))callBack{
    if (!_cloudMalls) {
        AVQuery *query = [AVQuery queryWithClassName:@"Mall"];
        query.maxCacheAge = 24 * 3600;
        query.cachePolicy = kAVCachePolicyCacheElseNetwork;
        [query includeKey:@"region,source"];
        [query orderByAscending:@"queue"];
        [query whereKey:MALL_CLASS_LOCALID notEqualTo:@""];
        [query whereKeyExists:MALL_CLASS_LOCALID];
        [query whereKey:@"ready" equalTo:@YES];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error && objects.count > 0) {
                NSMutableArray *malls = [NSMutableArray array];
                for (AVObject *object in objects) {
                    YTCloudMall *mall = [[YTCloudMall alloc]initWithAVObject:object];
                    [malls addObject:mall];
                }
                _cloudMalls = malls.copy;
            }else{
                _cloudMalls = nil;
            }
            if (callBack != nil) {
                callBack(_cloudMalls);
            }
        }];
    }else{
        if (callBack != nil) {
            callBack(_cloudMalls);
        }
    }
}

- (void)getAllLocalMallWithCallBack:(void (^)(NSArray *malls))callBack{
    if (!_localMalls) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *malls = [NSMutableArray array];
            FMResultSet *result = [_db executeQuery:@"select * from Mall where isNavi = ?", [NSNumber numberWithInteger:1]];
            while ([result next]) {
                YTLocalMall *mall = [[YTLocalMall alloc]initWithDBResultSet:result];
                [malls addObject:mall];
            }
            _localMalls = malls.copy;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callBack != nil) {
                    callBack(_localMalls);
                }
            });
        });
    }else{
        if (callBack != nil) {
            callBack(_localMalls);
        }
    }
    
}

-(id<YTMall>)changeMallObject:(id<YTMall>)mall resultType:(YTMallClass)mallClass{
    if ([mall isMemberOfClass:[YTLocalMall class]]){
        switch (mallClass) {
            case YTMallClassCloud:{
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.localDB == %@",[mall identifier]];
                NSArray *cloudMall = [_cloudMalls filteredArrayUsingPredicate:predicate];
                if (cloudMall.count > 0) {
                    mall = cloudMall.firstObject;
                }
                if (!mall){
                    return nil;
                }
                return mall;
            }
            case YTMallClassLocal:
                return mall;
        }
    }else if ([mall isMemberOfClass:[YTCloudMall class]]){
        switch (mallClass) {
            case YTMallClassCloud:
                return mall;
            case YTMallClassLocal:{
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.identifier == %@",[mall localDB]];
                NSArray *localMall = [_localMalls filteredArrayUsingPredicate:predicate];
                if (localMall.count > 0) {
                    mall = localMall[0];
                }else{
                   FMResultSet *result = [[YTDataManager defaultDataManager].database executeQuery:@"SELECT * FROM Mall WHERE mallId = ?",[NSNumber numberWithInteger:[mall localDB].integerValue]];
                    if ([result next]){
                        mall = [[YTLocalMall alloc]initWithDBResultSet:result];
                    }else{
                        mall = nil;
                    }
                }
                return mall;
            }
        }
    }else{
        return nil;
    }
}

- (NSArray *)localMallsFromRegion:(YTRegion *)region{
    if (!region){
        return _localMalls;
    }
    NSMutableArray *localMalls = [NSMutableArray new];
    for (YTLocalMall *tmpMall in _localMalls) {
        if ([[tmpMall region].name isEqualToString:region.name]){
            [localMalls addObject:localMalls];
        }
    }
    return localMalls.copy;
}
- (NSArray *)cloudMallsFromRegion:(YTRegion *)region{
    if (!region){
        return _cloudMalls;
    }
    
    NSMutableArray *cloudMalls = [NSMutableArray new];
    for (YTCloudMall *tmpMall in _cloudMalls) {
        if ([[tmpMall region]isEqual:region]) {
            [cloudMalls addObject:tmpMall];
        }
    }
    return cloudMalls.copy;
}

- (NSArray *)threeRandomMallDoesNotContainRegion:(YTRegion *)region{
    NSArray *source = _cloudMalls;
    if (region) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.region.name != %@",region.name];
        source = [source filteredArrayUsingPredicate:predicate];
    }
    if (source.count > 3) {
    
        NSMutableArray *tmpMall = [NSMutableArray arrayWithArray:source];
        
        NSInteger mallIndex = arc4random() % tmpMall.count;
        YTCloudMall *mall_1 = tmpMall[mallIndex];
        [tmpMall removeObject:mall_1];
        
        mallIndex = arc4random() % tmpMall.count;
        YTCloudMall *mall_2 = tmpMall[mallIndex];
        [tmpMall removeObject:mall_2];
        
        mallIndex = arc4random() % tmpMall.count;
        YTCloudMall *mall_3 = tmpMall[mallIndex];
        
        source = @[mall_1,mall_2,mall_3];
        
        [tmpMall removeAllObjects];
        tmpMall = nil;
    }
    return source;
}

- (id<YTMall>)getMallFromIdentifier:(NSString *)identifier{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@",identifier];
    if (identifier.length < 24) {
        //返回本地数据
        if (_localMalls == nil) {
            return nil;
        }
        return [_localMalls filteredArrayUsingPredicate:predicate][0];
    }else{
        //返回云端数据
        if (_cloudMalls == nil) {
            return nil;
        }
        return [_cloudMalls filteredArrayUsingPredicate:predicate][0];
    }
}

- (YTLocalFloor *)firstFloorFromMallLocalId:(NSString *)localDBId{
    FMDatabase *db = [YTDataManager defaultDataManager].database;
    NSString *sql = [NSString stringWithFormat:@"select * from Floor where floorName = \"L1\" and mallId = %@",localDBId];
    FMResultSet *result = [db executeQuery:sql];
    YTLocalFloor *floor;
    if ([result next]) {
        floor  = [[YTLocalFloor alloc]initWithDBResultSet:result];
    }
    return floor;
}

- (void)refershLocalMall{
    _localMalls = nil;
    [self getAllLocalMallWithCallBack:nil];
}

- (void)refershCloudMall{
    _cloudMalls = nil;
    [self getAllCloudMallWithCallBack:nil];
}

@end
