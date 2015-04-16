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
    NSString *_tmpMallId;
    NSString *_tmpMallName;
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
            _titleImage = [UIImage imageWithData:[findResultSet dataForColumn:@"title_img"]];
            _background = [UIImage imageWithData:[findResultSet dataForColumn:@"background_img"]];
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
