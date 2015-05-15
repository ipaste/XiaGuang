//
//  YTMallActivity.m
//  虾逛
//
//  Created by Yuntop on 15/5/7.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTMallActivity.h"
#import "AVFile.h"
#import "YTCloudMall.h"

#define MALLACTIVITY_KEY_ACTIVITY @"activity"
#define MALLACTIVITY_KEY_MALL @"mall"

@implementation YTMallActivity
{
    AVObject *_object;
    YTCloudMall *_mall;
}

- (instancetype)initWithCloudObject:(AVObject *)object {
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

- (void)getMallInstanceWithCallBack:(void (^)(YTCloudMall *))callBack {
    if (!_mall) {
        AVObject *cloudMall = _object[MALLACTIVITY_KEY_MALL];
        _mall = [[YTCloudMall alloc]initWithAVObject:cloudMall];
        callBack(_mall);
        }
    else {
        callBack (_mall);
    }
}

- (void)getActivityImgWithCallBack:(void (^)(UIImage *, NSError *))callBack {
    AVFile *file = _object[MALLACTIVITY_KEY_ACTIVITY];
    if (file) {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                callBack([UIImage imageWithData:data],nil);
            }
        }];
    }else {
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
