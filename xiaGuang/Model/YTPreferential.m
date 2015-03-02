//
//  YTPreferential.m
//  虾逛
//
//  Created by YunTop on 15/2/5.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTPreferential.h"
#import "AVFile.h"
#import "YTCloudMerchant.h"

#define PREFERENTIAL_KEY_THUMBNAIL @"thumbnail"
#define PREFERENTIAL_KEY_PREFERENTIALINFORMATION @"info"
#define PREFERENTIAL_KEY_ORIGINALPRICE @"originalPrice"
#define PREFERENTIAL_KEY_FAVORABLEPRICE @"favorablePrice"
#define PREFERENTIAL_KEY_MERCHANT @"merchant"
@implementation YTPreferential
{
    AVObject *_object;
    YTCloudMerchant *_merchant;
    YTPreferentialType _source;
    NSDictionary *_dzdpDictionary;
}

- (instancetype)initWithCloudObject:(AVObject *)object{
    self = [super init];
    if (self) {
        _object = object;
        _source = YTPreferentialTypeSole;
    }
    return self;
}

-(instancetype)initWithDaZhongDianPing:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        _dzdpDictionary = dictionary;
        _source = YTPreferentialTypeOther;
    }
    return self;
}

- (NSString *)identifier{
    //identifier
    if (_source == YTPreferentialTypeOther)
    {
        return nil;
    }
    return _object.objectId;
}

- (NSString *)preferentialInfo{
    //优惠信息
    if (_source == YTPreferentialTypeOther) {
        NSString *string = _dzdpDictionary[@"description"];
        if ([string rangeOfString:@" "].length > 0 ){
            return [string componentsSeparatedByString:@" "][1];
        }
        return string;
    }
    return _object[PREFERENTIAL_KEY_PREFERENTIALINFORMATION];
}

- (NSString *)time{
    return @"fuck - fucking";
}

- (NSNumber *)originalPrice{
    //原价
    if (_source == YTPreferentialTypeOther) {
        NSLog(@"原价 : %@",_dzdpDictionary[@"list_price"]);
        return _dzdpDictionary[@"list_price"];
    }
    return _object[PREFERENTIAL_KEY_ORIGINALPRICE];
}

-(NSNumber *)favorablePrice{
    //优惠价
    if (_source == YTPreferentialTypeOther) {
        NSLog(@"优惠价: %@",_dzdpDictionary[@"current_price"]);
        return _dzdpDictionary[@"current_price"];
    }
    return _object[PREFERENTIAL_KEY_FAVORABLEPRICE];
}

-(YTPreferentialType)type{
    return _source;
}

- (void)getMerchantInstanceWithCallBack:(void (^)(YTCloudMerchant * merchant))callBack{
    if (!_merchant) {
        if (_source == YTPreferentialTypeOther) {
            AVQuery *query = [AVQuery queryWithClassName:@"Merchant"];
            [query whereKey:@"shopId" containedIn:[self shopIdFromBusinesses:_dzdpDictionary[@"businesses"]]];
            [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                if (error == nil) {
                    _merchant = [[YTCloudMerchant alloc]initWithAVObject:object];
                    callBack(_merchant);
                }else{
                    callBack(nil);
                }
                
            }];
        }else{
            AVObject *cloudMerchant = _object[PREFERENTIAL_KEY_MERCHANT];
            if (cloudMerchant == nil) {
                return  nil;
            }
            _merchant = [[YTCloudMerchant alloc]initWithAVObject:cloudMerchant];
            callBack(_merchant);
        }
    }else{
        callBack(_merchant);
    }
}

- (void)getThumbnailWithCallBack:(void (^)(UIImage *, NSError *))callBack{
    if (_source == YTPreferentialTypeOther){
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]init];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:_dzdpDictionary[@"s_image_url"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            callBack([UIImage imageWithData:responseObject],nil);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            callBack(nil,error);
        }];
        return;
    }
    AVFile *file = _object[PREFERENTIAL_KEY_THUMBNAIL];
    if (file) {
        [file getThumbnail:true width:100 height:100 withBlock:callBack];
    }else{
        NSError *error = [NSError errorWithDomain:@"com.xiaShopping" code:400 userInfo:nil];
        callBack(nil,error);
    }
}

- (NSArray *)shopIdFromBusinesses:(NSArray *)businesses
{
    NSMutableArray *shopIds = [NSMutableArray array];
    for (NSDictionary *businesse in businesses) {
        NSNumber * number = businesse[@"id"];
        [shopIds addObject:number.stringValue];
    }
    return shopIds.copy;
}

@end
