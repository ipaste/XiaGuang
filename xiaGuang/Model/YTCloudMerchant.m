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
    
    DPRequest *_request;
    
    BOOL _isLoadCloud;
}
@end
@implementation YTCloudMerchant
-(id)initWithAVObject:(AVObject *)object{
    self = [super init];
    if (self) {
        _object = object;
        _isLoadCloud = true;
       
    }
    return self;
}
-(NSString *)mercantId{
    return _object.objectId;
}

-(NSString *)merchantName{
    return _object[MERCHANT_CLASS_NAME_KEY];
}



-(NSString *)type{
    NSString *type = _object[MERCHANT_CLASS_TYPE_KEY];

    return type;
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
        FMDatabase *db = [YTDataManager defaultDataManager].database;
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

    if (_isLoadCloud) {
        NSNumber *shopId = [NSNumber numberWithDouble:[self shopId].doubleValue];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[shopId] forKeys:@[@"business_id"]];
        _request = [DPRequest requestWithURL:@"http://api.dianping.com/v1/business/get_single_business" params:params delegate:self];
        [_request connectWithCallBack:^(id result) {
            if ([result[@"status"] isEqualToString:@"OK"] && [result[@"count"] compare:@0] == NSOrderedDescending){
                if ([result[@"businesses"][0][@"has_deal"] isEqual:@1]) {
                    _isOther = true;
                }
            }else{
                _isOther = false;
            }
            
            AVQuery *query = [AVQuery queryWithClassName:@"PreferentialInformation"];
            [query whereKey:@"merchant" equalTo:_object];
            [query whereKey:@"switch" equalTo:@YES];
            [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError *error) {
                if (number > 0) {
                    _isSole = true;
                    callBack(_isSole);
                }else{
                    _isSole = false;
                    if (_isOther) {
                        callBack(_isOther);
                    }else{
                        callBack(_isSole);
                    }
                }
                _isLoadCloud = false;
            }];
        }];
    }else{
        if (!_isSole && !_isOther) {
            callBack(false);
        }else{
            callBack(true);
        }
    }
}

-(void)merchantWithPreferentials:(void (^)(NSArray *, NSError *))callBack{
    NSMutableArray *preferentials = [NSMutableArray array];
    AVQuery *query = [AVQuery queryWithClassName:@"PreferentialInformation"];
    [query whereKey:@"merchant" equalTo:_object];
    [query whereKey:@"switch" equalTo:@YES];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil){
            for (AVObject *object in objects) {
                YTPreferential *preferential = [[YTPreferential alloc]initWithCloudObject:object];
                [preferentials addObject:preferential];
            }
        }
        
        if (_isOther) {
            NSNumber *shopId = [NSNumber numberWithDouble:[self shopId].doubleValue];
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[shopId,@"深圳"] forKeys:@[@"business_id",@"city"]];
            DPRequest *request = [DPRequest requestWithURL:@"http://api.dianping.com/v1/deal/get_deals_by_business_id" params:params delegate:self];
            [request connectWithCallBack:^(id result) {
                if ([result[@"status"] isEqualToString:@"OK"],[result[@"count"] compare:@0] == NSOrderedDescending){
                    for (NSDictionary *deal in result[@"deals"]) {
                        YTPreferential *tmpPreferential = [[YTPreferential alloc]initWithDaZhongDianPing:deal];
                        [preferentials addObject:tmpPreferential];
                    }
                    
                    callBack(preferentials.copy,nil);
                }else{
                    callBack(nil,error);
                }
            }];
        }else{
            if (preferentials.count <= 0) {
                callBack(nil,error);
            }else{
                callBack(preferentials.copy,nil);
            }
        }
        
    }];
}

- (void)getSolePreferentials:(void (^)(NSArray *preferentials,NSError *error))callBack
{
    if (_isSole) {
        AVQuery *query = [AVQuery queryWithClassName:@"PreferentialInformation"];
        [query whereKey:@"merchant" equalTo:_object];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error == nil) {
                NSMutableArray *array = [NSMutableArray array];
                for (AVObject *object in objects) {
                    YTPreferential *preferential = [[YTPreferential alloc]initWithCloudObject:object];
                    [array addObject:preferential];
                }
                callBack(array,error);
            }else{
                callBack(nil,error);
            }
        }];
    }
}

- (void)getOtherPreferentials:(void (^)(NSArray *preferentials,NSError *error))callBack
{
    if (_isOther) {
        NSError *error = [[NSError alloc]initWithDomain:@"xiashopping.com" code:404 userInfo:nil];
        NSMutableArray *array = [NSMutableArray array];
        NSNumber *shopId = [NSNumber numberWithDouble:[self shopId].doubleValue];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[shopId,@"深圳"] forKeys:@[@"business_id",@"city"]];
        DPRequest *request = [DPRequest requestWithURL:@"http://api.dianping.com/v1/deal/get_deals_by_business_id" params:params delegate:self];
        [request connectWithCallBack:^(id result) {
            if ([result[@"status"] isEqualToString:@"OK"],[result[@"count"] compare:@0] == NSOrderedDescending){
                for (NSDictionary *deal in result[@"deals"]) {
                    YTPreferential *tmpPreferential = [[YTPreferential alloc]initWithDaZhongDianPing:deal];
                    [array addObject:tmpPreferential];
                }
                
                callBack(array.copy,nil);
            }else{
                callBack(nil,error);
            }
        }];

    }
}

- (NSString *)shopId{
    return _object[@"shopId"];
}

-(void)dealloc
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       [[NSURLCache sharedURLCache]removeAllCachedResponses];
    });
}

@end
