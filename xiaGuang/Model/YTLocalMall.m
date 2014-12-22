//
//  YTLocalMall.m
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTLocalMall.h"
#import "YTCloudMall.h"
@implementation YTLocalMall{
    NSString *_tmpMallId;
    NSString *_tmpMallName;
    CGFloat _offset;
    NSMutableArray *_tmpBlocks;
    NSMutableArray *_tmpMerchantInstance;
    UIImage *_titleImage;
    UIImage *_background;
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
        
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
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
        
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
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
    if (_titleImage == nil || _background == nil) {
        __block AVObject *internalObject = nil;
        __block UIImage *titleImage = nil;
        __block UIImage *background = nil;
        __block NSError *error = [[NSError alloc]initWithDomain:@"com.xiashopping" code:404 userInfo:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            AVQuery *query = [AVQuery queryWithClassName:@"Mall"];
            [query whereKey:@"localDBId" equalTo:[self identifier]];
            internalObject = [query getFirstObject];
            titleImage = [UIImage imageWithData:[internalObject[@"mall_img_title"] getData]];
            background = [UIImage imageWithData:[internalObject[@"mall_img_background"] getData]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (titleImage != nil && background != nil) {
                    _background = background;
                    _titleImage = titleImage;
                    callback(titleImage,background,nil);
                }else{
                    callback(nil,nil,error);
                }
            });
            
        });
    }else{
        
        callback(_titleImage,_background,nil);
    }
}

-(YTCloudMall *)getCloudMall{
    AVQuery *query = [AVQuery queryWithClassName:@"Mall"];
    [query whereKey:@"localDBId" equalTo:[self identifier]];
    AVObject *mall = [query getFirstObject];
    if (mall == nil) {
        return nil;
    }
    return [[YTCloudMall alloc]initWithAVObject:mall];
}
@end
