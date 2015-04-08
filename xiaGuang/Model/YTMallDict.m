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
        _db = [YTStaticResourceManager sharedManager].db;
    }
    return self;
}

- (NSNumber *)localMallMaxId{
    FMResultSet *result = [_db executeQuery:@"select count(*) from Mall"];
    [result next];
    return (NSNumber *)[result objectAtIndexedSubscript:0];
}

- (BOOL)loadFinishes{
    if (_localMalls != nil && _cloudMalls != nil) {
        return true;
    }
    return false;
}

- (void)getAllCloudMallWithCallBack:(void (^)(NSArray *malls))callBack{
    if (!_cloudMalls) {
        AVQuery *query = [AVQuery queryWithClassName:@"Mall"];
        query.maxCacheAge = 24 * 3600;
        query.cachePolicy = kAVCachePolicyCacheElseNetwork;
        [query whereKey:MALL_CLASS_LOCALID notEqualTo:@""];
        [query whereKeyExists:MALL_CLASS_LOCALID];
        [query whereKey:MALL_CLASS_LOCALID lessThanOrEqualTo:self.localMallMaxId];
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
            FMResultSet *result = [_db executeQuery:@"select * from Mall"];
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
                    mall = nil;
                }
                return mall;
            }
        }
    }else{
        return nil;
    }
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
    FMDatabase *db = [YTStaticResourceManager sharedManager].db;
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
