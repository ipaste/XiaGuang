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
#import "YTPreferential.h"
@interface YTCloudMerchant(){
    AVObject *_object;
    
    YTLocalMerchantInstance *_tmpMerchantInstance;
    
    UIImage *_icon;
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
    if (_icon == nil) {
        AVFile *file = _object[MERCHANT_CLASS_ICON_KEY];
        [file getThumbnail:true width:200 height:200 withBlock:^(UIImage *image, NSError *error) {
            if (image != nil) {
                _icon = image;
                callback(_icon,nil);
            }else{
                callback(nil,error);
            }
        }];
    }else{
        callback(_icon,nil);
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

-(NSString *)uniId{
    return _object[@"uniId"];
}

-(void)existenceOfPreferentialInformationQueryMall:(void (^)(BOOL))callBack{
    AVQuery *query = [AVQuery queryWithClassName:@"PreferentialInformation"];
    [query whereKey:@"merchant" equalTo:_object];
    [query whereKey:@"swicth" equalTo:@YES];
    [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError *error) {
        if (number > 0) {
            callBack(true);
        }else{
            callBack(false);
        }
    }];
}

-(void)merchantWithPreferentials:(void (^)(NSArray *, NSError *))callBack{
    AVQuery *query = [AVQuery queryWithClassName:@"PreferentialInformation"];
    [query whereKey:@"merchant" equalTo:_object];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *preferentials = [NSMutableArray array];
        for (AVObject *object in objects) {
            YTPreferential *preferential = [[YTPreferential alloc]initWithCloudObject:object];
            [preferentials addObject:preferential];
        }
        if (error) {
            preferentials = nil;
        }
        callBack(preferentials,error);
    }];

}
@end
