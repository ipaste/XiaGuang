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
}

- (instancetype)initWithCloudObject:(AVObject *)object{
    self = [super init];
    if (self) {
        _object = object;
    }
    return self;
}

- (NSString *)identifier{
    //identifier
    return _object.objectId;
}

- (NSString *)preferentialInfo{
    //优惠信息
    return _object[PREFERENTIAL_KEY_PREFERENTIALINFORMATION];
}

- (NSNumber *)originalPrice{
    //原价
    return _object[PREFERENTIAL_KEY_ORIGINALPRICE];
}

-(NSNumber *)favorablePrice{
    //优惠价
    return _object[PREFERENTIAL_KEY_FAVORABLEPRICE];
}

- (YTCloudMerchant *)merchant{
    if (!_merchant) {
        AVObject *cloudMerchant = _object[PREFERENTIAL_KEY_MERCHANT];
        if (cloudMerchant == nil) {
            return  nil;
        }
        _merchant = [[YTCloudMerchant alloc]initWithAVObject:cloudMerchant];
    }
    return _merchant;
}

- (void)getThumbnailWithCallBack:(void (^)(UIImage *, NSError *))callBack{
    AVFile *file = _object[PREFERENTIAL_KEY_THUMBNAIL];
    if (file) {
        [file getThumbnail:true width:100 height:100 withBlock:callBack];
    }else{
        NSError *error = [NSError errorWithDomain:@"com.xiaShopping" code:400 userInfo:nil];
        callBack(nil,error);
    }
    
}


@end
