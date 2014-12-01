//
//  YTCloudMerchant.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-17.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTCloudMerchant.h"
#import <AVFile.h>
#import "YTCloudMall.h"

@interface YTCloudMerchant(){
    AVObject *_object;
    
    YTLocalMerchantInstance *_tmpMerchantInstance;
}
@end
@implementation YTCloudMerchant
-(id)initWithAVObject:(AVObject *)object{
    self = [super init];
    if (self) {
        _object = object;
       
    }
    return self;
}
-(NSString *)mercantId{
    return _object.objectId;
}

-(NSString *)merchantName{
    return _object[MERCHANT_CLASS_NAME_KEY];
}

-(NSArray *)type{
    NSString *type = _object[MERCHANT_CLASS_TYPE_KEY];
    if (type.length <= 0 || type == nil) {
        return nil;
    }
    NSMutableArray *types = [NSMutableArray arrayWithArray:[type componentsSeparatedByString:@" "]];
    if ([[types lastObject] isEqualToString:@""]) {
        [types removeLastObject];
    }
    return types;
}

-(NSString *)shortName{
    return _object[MERCHANT_CLASS_SHORTNAME_KEY];
}

-(UIImage *)icon{
    AVFile *file = _object[MERCHANT_CLASS_ICON_KEY];
   
    return [UIImage imageWithData:[file getData]];
}

-(NSString *)address{
    return _object[MERCHANT_CLASS_ADDRESS_KEY];
}

-(id<YTMall>)mall{
    AVObject *mallObject = _object[MERCHANT_CLASS_MALL_KEY];
    return [[YTCloudMall alloc]initWithAVObject:mallObject];
}

-(id<YTFloor>)floor{
    AVObject *floorObject = _object[MERCHANT_CLASS_FLOOR_KEY];
    YTCloudFloor *floor = [[YTCloudFloor alloc]initWithAVObject:floorObject];
    return floor;
}
-(void)getThumbNailWithCallBack:(void (^)(UIImage *result,NSError *error))callback{
    
    AVFile *file = _object[MERCHANT_CLASS_ICON_KEY];
    if (file != nil) {
        [file getThumbnail:YES width:200 height:200 withBlock:callback];
    }else{
        callback(nil,nil);
    }

}

-(YTLocalMerchantInstance *)getLocalMerchantInstance{
    NSString *uniId = _object[@"uniId"];
    if ([uniId isEqualToString:@"0"] || uniId == nil) {
        return nil;
    }
    
    if(_tmpMerchantInstance == nil){
        
        FMDatabase *db = [YTStaticResourceManager sharedManager].db;
        if([db open]){
            
            FMResultSet *result = [db executeQuery:@"select * from MerchantInstance where uniId = ?",_object[@"uniId"]];
            [result next];
            
            _tmpMerchantInstance = [[YTLocalMerchantInstance alloc] initWithDBResultSet:result];
        }
    }
    return _tmpMerchantInstance;
    
}
-(NSString *)localDBId{
    return _object[@"localDBId"];
}
@end
