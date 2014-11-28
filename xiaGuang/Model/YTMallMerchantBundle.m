//
//  YTMallMerchantBundle.m
//  HighGuang
//
//  Created by Yuan Tao on 10/14/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTMallMerchantBundle.h"
#import "YTCloudMall.h"
@implementation YTMallMerchantBundle{
    id<YTMall> _mall;
    NSMutableArray *_tmpMerchants;
    NSMutableArray *_tmpIcons;
    int _num;
    
    NSDate *_dateNow;
}

-(id)initWithMall:(id<YTMall>)mall{
    self = [super init];
    if(self){
        _mall = mall;
        _tmpMerchants = [[NSMutableArray alloc] init];
        _tmpIcons = [[NSMutableArray alloc] init];
        _dateNow = [NSDate date];
    }
    return self;
}

-(void)mallInfoTitleWithCallBack:(void (^)(UIImage *result,NSError* error))callback{
    [_mall getMallTitleWithCallBack:^(UIImage *result, NSError *error) {
        if(error != nil){
            NSLog(@"找不到此mall的info image");
            return;
        }
        _mallInfoImage = result;
        _mallInfoImageReady = YES;
        callback(_mallInfoImage,nil);
    }];
}

-(void)mallBackgroundWithCallBack:(void (^)(UIImage *result,NSError* error))callback{
    [_mall getBackgroundWithCallBack:^(UIImage *result, NSError *error) {
        if(error != nil){
            NSLog(@"找不到此mall的background image");
            return;
        }
        
        _mallBackgroundImage = result;
        _mallBackgroundImageReady = YES;
        callback(_mallBackgroundImage,nil);
    }];
}
-(void)time:(NSTimer *)timer{
    NSLog(@"%d",_num);
    _num++;
}
@end
