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
        AVQuery *query = [AVQuery queryWithClassName:@"Mall"];
        [query whereKey:@"localDBId" equalTo:[self identifier]];
        [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            if (_titleImage == nil) {
                [object[@"mall_img_title"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (error) {
                        callback(nil,nil,error);
                        return ;
                    }
                    _titleImage = [UIImage imageWithData:data];
                    callback(_titleImage,_background,error);
                }];
            }
            if (_background == nil) {
                [object[@"mall_img_background"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (error) {
                        callback(nil,nil,error);
                        return ;
                    }
                    _background = [UIImage imageWithData:data];
                    callback(_titleImage,_background,error);
                }];
            }
        }];
    }else{
        callback(_titleImage,_background,nil);
    }
}

@end
