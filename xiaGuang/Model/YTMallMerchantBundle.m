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



-(void)getIconsWithCallBack:(void (^)(NSArray *result,NSError* error))callback{
    
    AVQuery *query = [AVQuery queryWithClassName:@"Merchant"];
    
    query.cachePolicy = kAVCachePolicyNetworkElseCache;
    
    [query whereKey:@"mall" equalTo: [(YTCloudMall *)_mall getCloudObj]];
    [query includeKey:@"mall,Icon"];
    [query whereKeyExists:@"Icon"];
    query.maxCacheAge = 3600 * 24;
    query.limit = 20;
    
    
    NSString *timeSp = [NSString stringWithFormat:@"%f", (double)[_dateNow timeIntervalSinceNow]];
    NSLog(@"before find timeSp:%@",timeSp);
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
            NSString *timeSp = [NSString stringWithFormat:@"%f", (double)[_dateNow timeIntervalSinceNow]];
            NSLog(@"callback timeSp:%@",timeSp);
            if(error != nil){
                callback(nil,error);
                return;
            }

            
             __block int count = 0;
             for(AVObject *tmp in objects){
             
             
             YTCloudMerchant * tmpMerchant = [[YTCloudMerchant alloc] initWithAVObject:tmp];
             
             
             [tmpMerchant getThumbNailWithCallBack:^(UIImage *result, NSError *error) {
             
             if(result == nil){
             NSLog(@"nil thumbnail");
                 return;
             }
             if (error != nil) {
             NSLog(@"thumbnail error");
                 return;
             
             }
            // NSLog(@"count is %d", count);
             
             
             [_tmpMerchants addObject:tmpMerchant];
             [_tmpIcons addObject:result];
             
             if(count >= 20-1){
             _icons = _tmpIcons;
             _merchants = _tmpMerchants;
             _merchantsIconReady = YES;
             
             callback(_icons,nil);
             }
             
             count++;
             }];
             
             }
            
            
            
    }];

    timeSp = [NSString stringWithFormat:@"%f", (double)[_dateNow timeIntervalSinceNow]];
    NSLog(@"after find timeSp:%@",timeSp);
 
}
-(void)time:(NSTimer *)timer{
    NSLog(@"%d",_num);
    _num++;
}
@end
