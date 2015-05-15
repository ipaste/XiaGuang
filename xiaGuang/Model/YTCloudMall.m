//
//  YTCloudMall.m
//  HighGuang
//
//  Created by Yuan Tao on 8/13/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTCloudMall.h"
#import "YTMallDict.h"
#import "YTCloudMerchant.h"
#define MALL_CLASS_NAME @"Mall"
#define MALL_CLASS_MALLNAME_KEY @"name"
typedef void(^YTGetTitleImageAndBackgroundImageCallBack)(UIImage *titleImage,UIImage *background,NSError *error);
typedef void(^YTExistenceOfPreferentialInformationCallBack)(BOOL isExistence);

@implementation YTCloudMall{
    AVObject *_internalObject;
    UIImage *_titleImage;
    UIImage *_background;
    NSMutableArray *_blocks;
    NSMutableArray *_merchantLocs;
    NSMutableArray *_merchants;
    NSMutableArray *_resultArray;
    NSMutableArray *_resultMerchants;
    NSNumber *_isExistence;
    YTLocalMall *_tmpLocalMall;
    DPRequest *_request;
    YTRegion *_region;
    YTGetTitleImageAndBackgroundImageCallBack _callBack;
    YTExistenceOfPreferentialInformationCallBack _existenceCallBack;

    YTMallDict *_mallDict;
}

@synthesize mallName;
@synthesize identifier;
@synthesize blocks;
@synthesize merchants;

-(id)initWithAVObject:(AVObject *)object{
    self = [super init];
    if(self){
        _internalObject = object;
        _mallDict = [YTMallDict sharedInstance];
    }
    return self;
}

-(AVFile *)getMallFile{
    return _internalObject[@"source"][@"data"];
}

- (BOOL)isShowPath{
    FMResultSet *result = [[YTDataManager defaultDataManager].database executeQuery:@"SELECT path FROM Mall WHERE MallId = ?",[NSNumber numberWithInt:[[self localDB] intValue]]];
    [result next];
    return [result intForColumn:@"path"] == 0 ? false:true;
}

- (NSString *)uniId{
    return ((NSNumber *)_internalObject[MALL_CLASS_LOCALID]).stringValue;
}

- (CLLocationCoordinate2D)coord{
    NSNumber *latitude = _internalObject[@"latitude"];
    NSNumber *longitude = _internalObject[@"longitude"];
    return CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
}

-(NSString *)mallName{
    return _internalObject[MALL_CLASS_MALLNAME_KEY];
}

-(NSString *)identifier{
    return _internalObject.objectId;
}

- (NSString *)version{
    return _internalObject[@"source"][@"version"];
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
- (YTRegion *)region{
    if (!_region) {
        NSInteger identify = [_internalObject[MALL_CLASS_REGION][@"uniId"] integerValue];
        _region = [[YTRegion alloc]initWithIdentify:identify];
    }
    return _region;
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
-(void)getMallImgBackground:(void (^)(UIImage *result,NSError* error))callback{
    AVFile *file = _internalObject[@"mall_img_background"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *mallImage = [UIImage imageWithData:data];
            callback(mallImage,nil);
        }else{
            callback(nil,error);
        }
    }];
}

-(void)getPosterTitleImageAndBackground:(void(^)(UIImage *titleImage,UIImage *background,NSError *error))callback{
    
    if (_background == nil && _titleImage == nil) {
        _callBack = nil;
        _callBack = callback;
        [_internalObject[MALL_CLASS_BIGTITLE_KEY] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error) {
                callback(nil,nil,error);
                return ;
            }
            _titleImage = [UIImage imageWithData:data];
            [self checkCallBackConditions];
        }];
        [_internalObject[MALL_CLASS_BIGBACKGROUND_KEY] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error) {
                callback(nil,nil,error);
                return ;
            }
            _background = [UIImage imageWithData:data];
            [self checkCallBackConditions];
        }];
    }else{
        callback(_titleImage,_background,nil);
    }

}

- (BOOL)checkCallBackConditions{
    if (_titleImage != nil && _background != nil) {
        _callBack(_titleImage,_background,nil);
        return true;
    }else{
        return false;
    }
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

-(void)getMallBasicMallInfoWithCallBack:(void(^)(NSString *mallName,NSString *address,CLLocationCoordinate2D coord,NSError *error))callback{
    NSString *add = _internalObject[@"address"];
    NSString *name = _internalObject[MALL_CLASS_MALLNAME_KEY];
    CLLocationCoordinate2D coordinate = [self coord];
    callback(name,add,coordinate,nil);
}

-(NSString *)localDB{
    return ((NSNumber *)_internalObject[MALL_CLASS_LOCALID]).stringValue;
}

-(YTLocalMall *)getLocalCopy{
    if(_tmpLocalMall == nil){
        NSString *uniId = _internalObject[MALL_CLASS_LOCALID];
        if (uniId == nil || uniId.length <= 0) {
            return nil;
        }
        FMDatabase *db = [YTDataManager defaultDataManager].database;
        if([db open]){
            
            FMResultSet *result = [db executeQuery:@"select * from Mall where mallId = ?",uniId];
            [result next];
            
            _tmpLocalMall = [[YTLocalMall alloc] initWithDBResultSet:result];
        }
        
    }
    return _tmpLocalMall;
    
}

-(CGFloat)offset{
    return [_mallDict changeMallObject:self resultType:YTMallClassCloud].offset;
}

-(AVObject *)getCloudObj{
    return _internalObject;
}

-(void)existenceOfPreferentialInformationQueryMall:(void (^)(BOOL))callBack{
    if (!_isExistence) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:@"http://xiaguang.avosapps.com/existence_PreferentialInformation" parameters:@{@"objectId":_internalObject.objectId} success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject[@"exidtence"] isEqualToNumber:@1]) {
                _isExistence = [NSNumber numberWithBool:true];
            }else{
                _isExistence = [NSNumber numberWithBool:false];
            }
            callBack([_isExistence boolValue]);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            callBack(false);
        }];
    }else{
        callBack([_isExistence boolValue]);
    }
}


@end
