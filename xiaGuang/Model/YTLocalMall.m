//
//  YTLocalMall.m
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTLocalMall.h"
#import "YTCloudMall.h"

typedef void(^YTGetTitleImageAndBackgroundImageCallBack)(UIImage *titleImage,UIImage *background,NSError *error);
@implementation YTLocalMall{
    BOOL _isShowPath;
    NSString *_tmpMallId;
    NSString *_tmpMallName;
    NSString *_regionIdentify;
    YTRegion *_region;
    CGFloat _offset;
    NSMutableArray *_tmpBlocks;
    NSMutableArray *_tmpMerchantInstance;
    UIImage *_titleImage;
    UIImage *_background;
    YTGetTitleImageAndBackgroundImageCallBack _callBack;
}

@synthesize mallName;
@synthesize identifier;
@synthesize blocks;
@synthesize merchantLocations;

-(id)initWithDBResultSet:(FMResultSet *)findResultSet{
    if(findResultSet != nil){
        self = [super init];
        if(self){
            _tmpMallId = [findResultSet stringForColumn:@"mallId"];
            _tmpMallName = [findResultSet stringForColumn:@"mallName"];
            _offset = [findResultSet doubleForColumn:@"offset"];
            _regionIdentify = [findResultSet stringForColumn:@"regionIdentify"];
            _isShowPath = [findResultSet stringForColumn:@"path"] == 0 ? false:true;
        }
    }
    return self;
}

-(NSString *)mallName{
    return _tmpMallName;
}

-(NSString *)identifier{
    return _tmpMallId;
}

-(NSArray *)blocks{
    
    if(_tmpBlocks == nil){
        
        FMDatabase *db = [YTDataManager defaultDataManager].database;
        FMResultSet *resultSet = [db executeQuery:@"select * from Block where mallId = ?",_tmpMallId];
        
        _tmpBlocks = [[NSMutableArray alloc] init];
        
        while ([resultSet next]) {
            YTLocalBlock *tmp = [[YTLocalBlock alloc] initWithDBResultSet:resultSet];
            [_tmpBlocks addObject:tmp];
        }
        
    }
    
    return _tmpBlocks;
}

-(YTRegion *)region{
    if (!_region) {
        FMDatabase *db = [YTDataManager defaultDataManager].database;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Region WHERE identify = ?",_regionIdentify];
        [result next];
        _region = [[YTRegion alloc]initWithSqlResultSet:result];
    }
    return _region;
}

-(NSArray *)merchantLocations{
    
    if(_tmpMerchantInstance == nil){
        
        FMDatabase *db = [YTDataManager defaultDataManager].database;
        FMResultSet *resultSet = [db executeQuery:@"select * from MerchantInstance where mallId = ?",_tmpMallId];
        
        _tmpMerchantInstance = [[NSMutableArray alloc] init];
        
        while ([resultSet next]) {
            YTLocalMerchantInstance *tmp = [[YTLocalMerchantInstance alloc] initWithDBResultSet:resultSet];
            [_tmpMerchantInstance addObject:tmp];
        }
        
    }
    return _tmpMerchantInstance;
}


-(CGFloat)offset{
    return _offset;
}


- (BOOL)isShowPath{
    return _isShowPath;
}

-(void)getPosterTitleImageAndBackground:(void(^)(UIImage *titleImage,UIImage *background,NSError *error))callback{
    NSError *error = nil;
    if (_titleImage == nil && _background == nil) {
        error = [NSError errorWithDomain:@"xiashopping" code:404 userInfo:nil];
    }
    callback(_titleImage,_background,error);
}

-(BOOL)checkCallBackConditions{
    if (_titleImage != nil && _background != nil) {
        _callBack(_titleImage,_background,nil);
        _callBack = nil;
        return true;
    }else{
        return false;
    }
}
@end
