//
//  YTCloudMall.m
//  HighGuang
//
//  Created by Yuan Tao on 8/13/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTCloudMall.h"
#import "YTCloudMerchant.h"
#define MALL_CLASS_NAME @"Mall"
#define MALL_CLASS_MALLNAME_KEY @"name"

@implementation YTCloudMall{
    AVObject *_internalObject;
    NSMutableArray *_blocks;
    NSMutableArray *_merchantLocs;
    NSMutableArray *_merchants;
    NSMutableArray *_resultArray;
    NSMutableArray *_resultMerchants;
    YTLocalMall *_tmpLocalMall;
}

@synthesize mallName;
@synthesize identifier;
@synthesize blocks;
@synthesize merchants;

-(id) initWithAVObject:(AVObject *)object{
    
    self = [super init];
    if(self){
        _internalObject = object;
        
    }
    return self;
    
}

-(NSString *)mallName{
    return _internalObject[MALL_CLASS_MALLNAME_KEY];
}

-(NSString *)identifier{
    return _internalObject.objectId;
}

-(NSArray *)blocks{
    if(_blocks == nil){
        
        _blocks = [[NSMutableArray alloc] init];
        
        AVQuery *query = [[AVQuery alloc] initWithClassName:@"Block"];
        query.maxCacheAge = 24 * 3600;
        query.cachePolicy = kAVCachePolicyCacheElseNetwork;
        [query whereKey:@"mall" equalTo:_internalObject];
        [query includeKey:@"mall"];
        NSArray *result = [query findObjects];
        for(AVObject *tempAVObject in result){
            YTCloudBlock *block = [[YTCloudBlock alloc] initWithAVObject:tempAVObject];
            [_blocks addObject:block];
        }
    }
    
    return _blocks;
}
-(UIImage *)background{
    AVFile *file = _internalObject[MALL_CLASS_BACKGROUND_KEY];
    return [UIImage imageWithData:[file getData]];
}

-(void)getBackgroundWithCallBack:(void (^)(UIImage *result,NSError* error))callback{
    AVFile *file = _internalObject[MALL_CLASS_BACKGROUND_KEY];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        if(error != nil){
            callback(nil,error);
            return;
        }
        
        UIImage *mallImage = [UIImage imageWithData:data];
        callback(mallImage,nil);
    }];
}
-(void)getInfoBackgroundImageWithCallBack:(void (^)(UIImage *result,NSError* error))callback{
    AVFile *file = _internalObject[MALL_CLASS_INFO_KEY];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if(error != nil){
            callback(nil,error);
            return;
        }
        
        UIImage *mallImage = [UIImage imageWithData:data];
        callback(mallImage,nil);
    }];
}
-(UIImage *)logo{
    AVFile *file = _internalObject[MALL_CLASS_LOGO_KEY];
    return [UIImage imageWithData:[file getData]];
}
-(NSArray *)merchants{
    if(_merchants == nil){
        _merchants = [[NSMutableArray alloc] init];
        
        AVQuery *query = [[AVQuery alloc] initWithClassName:MERCHANT_CLASS_NAME];
        query.maxCacheAge = 24 * 3600;
        query.cachePolicy = kAVCachePolicyCacheElseNetwork;
        [query whereKey:MERCHANT_CLASS_MALL_KEY equalTo:_internalObject];
        [query includeKey:@"mall"];
        
        NSArray *result = [query findObjects];
        for(AVObject *tempAVObject in result){
            YTCloudMerchant *merchat = [[YTCloudMerchant alloc]initWithAVObject:tempAVObject];
            [_merchants addObject:merchat];
        }
    }
    
    return [_merchants copy];
}
//-(NSArray *)merchantLocations{
//    if(_merchantLocs == nil){
//        
//        _merchantLocs = [[NSMutableArray alloc] init];
//        
//        AVQuery *query = [[AVQuery alloc] initWithClassName:MERCHANTLOCATION_CLASS_NAME];
//        query.maxCacheAge = 24 * 3600;
//        query.cachePolicy = kAVCachePolicyCacheElseNetwork;
//        
//        [query whereKey:MERCHANTLOCATION_CLASS_MALL_KEY equalTo:_internalObject];
//        [query includeKey:@"mall,majorArea,floor,inMinorArea"];
//        NSArray *result = [query findObjects];
//        for(AVObject *tempAVObject in result){
//            YTCloudMerchant *merchat = [[YTCloudMerchant alloc]initWithAVObject:tempAVObject];
//            [_merchantLocs addObject:merchat];
//        }
//    }
//    
//    return _merchantLocs;
//}
-(CLLocationCoordinate2D)coord{
    return CLLocationCoordinate2DMake([_internalObject[MALL_CLASS_LATITUDE_KEY] floatValue], [_internalObject[MALL_CLASS_LONGITUDE_KEY] floatValue]);
}

-(UIImage *)infoBackground{
    AVFile *file = _internalObject[MALL_CLASS_INFO_KEY];
    return [UIImage imageWithData:[file getData]];
}

-(void)iconsFromStartIndex:(int)start
                     toEnd:(int)end
                  callBack:(void (^)(NSArray *result,NSError *error))callback{
    if(start == end){
        callback(nil,nil);
        return;
    }
    
    if(_merchants.count < end){
        callback(nil,nil);
        return;
    }
    
    NSMutableArray *resultArray = [NSMutableArray new];
    __block int count = 0;
    for(int i = start; i < MAXFLOAT; i++){
        id<YTMerchant> tmpMerchant = [_merchants objectAtIndex:i] ;
        [tmpMerchant getThumbNailWithCallBack:^(UIImage *result, NSError *error) {
            if(error){
                NSLog(@"getting thumbnail fail");
                callback(nil,error);
                return;
            }
            [resultArray addObject:result];
            
            if(count >= end - start - 1){
                
                callback(resultArray,nil);
            }
            
            if (result == nil) {
                count++;
            }
            
            
            
        }];
        
    }
}


-(void)iconsFromStartIndex:(int)start
                fetchCount:(int)numberOfIcons
                  callBack:(void (^)(NSArray *result,NSArray *merchants,NSError *error))callback{
    if (start + numberOfIcons > self.merchants.count) {
        callback(nil,nil,nil);
        return;
    }else if (start < 0 || numberOfIcons <= 0) {
        callback(nil,nil,nil);
        return;
    }
    if (_resultArray == nil && _resultMerchants == nil) {
        _resultArray = [NSMutableArray array];
        _resultMerchants = [NSMutableArray array];
    }
    
    int count = 0;
    for (int i = start ; i < start + numberOfIcons; i++) {
        id<YTMerchant> merchant = self.merchants[i];
        [merchant getThumbNailWithCallBack:^(UIImage *result, NSError *error) {
            if (error) {
                callback(nil,nil,error);
                return;
            }
            if(result && _resultArray.count < start + numberOfIcons){
                [_resultArray addObject:result];
                [_resultMerchants addObject:merchant];
            }
            if (count == numberOfIcons - 1) {
                
                if (_resultArray.count < numberOfIcons) {
                    int lackOfNumber = numberOfIcons - (int)_resultArray.count;
                    [self iconsFromStartIndex:numberOfIcons fetchCount:lackOfNumber callBack:^(NSArray *result, NSArray *merchants,NSError *error) {
                        callback(_resultArray,_resultMerchants,nil);
                    }];
                }else{
                    callback(_resultArray,_resultMerchants,nil);
                    
                }
                
            }
            
        }];
        count++;
        
    }
}


-(void)getMallInfoTitleCallBack:(void (^)(UIImage *result,NSError *error))callback{
    AVFile *file = _internalObject[MALL_CLASS_INFOIMAGE_KEY];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if(error != nil){
            callback(nil,error);
            return;
        }
        
        UIImage *mallImage = [UIImage imageWithData:data];
        callback(mallImage,nil);
    }];
}

-(void)getMallTitleWithCallBack:(void (^)(UIImage *result,NSError* error))callback{
    AVFile *file = _internalObject[MALL_CLASS_LOGO_KEY];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        if(error != nil){
            callback(nil,error);
            return;
        }
        
        UIImage *mallImage = [UIImage imageWithData:data];
        callback(mallImage,nil);
    }];
}
-(void)getMallBasicInfoWithCallBack:(void(^)(UIImage *mapImage,NSString *address,NSString *phoneNumber,NSError *error))callback{
    NSString *address = _internalObject[@"address"];
    NSString *phoneNumber = _internalObject[@"phoneNumber"];
    AVFile *file = _internalObject[@"mallMap"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *tmpImage = [UIImage imageWithData:data];
            callback(tmpImage,address,phoneNumber,nil);
        }
    }];

}
-(NSString *)localDB{
    if (_internalObject[@"localDBId"]) {
        return nil;
    }
    return @"";
}
-(YTLocalMall *)getLocalCopy{
    
    if(_tmpLocalMall == nil){
        NSString *localDBId = _internalObject[@"localDBId"];
        if (localDBId == nil || localDBId.length <= 0) {
            return nil;
        }
        FMDatabase *db = [YTDBManager sharedManager].db;
        if([db open]){
            
            FMResultSet *result = [db executeQuery:@"select * from Mall where mallId = ?",localDBId];
            [result next];
            
            _tmpLocalMall = [[YTLocalMall alloc] initWithDBResultSet:result];
        }
       
    }
    return _tmpLocalMall;
    
}

-(AVObject *)getCloudObj{
    return _internalObject;
}

@end
