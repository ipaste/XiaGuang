//
//  YTLocalMerchantInstance.m
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTLocalMerchantInstance.h"
#import "YTMerchantPoi.h"
@implementation YTLocalMerchantInstance{
    NSString *_tmpMerchantInstanceId;
    NSString *_tmpMallId;
    NSString *_tmpMerchantInstanceName;
    NSString *_tmpMajorAreaId;
    double _tmpLatitude;
    double _tmpLongtitude;
    NSString *_tmpMinorAreaId;
    float _tmpDisplayLevel;
    NSString *_tmpFloorId;
    NSString *_tmpAddress;
    
    float _tmpLableHeight;
    float _tmpLableWidth;
    
    id<YTMall> _tmpMall;
    id<YTFloor> _tmpFloor;
    id<YTMajorArea> _tmpMajorArea;
    id<YTMinorArea> _tmpMinorArea;
}


@synthesize mall;
@synthesize majorArea;
@synthesize identifier;
@synthesize merchantLocationName;
@synthesize floor;
@synthesize coordinate;
@synthesize displayLevel;
@synthesize inMinorArea;
@synthesize address;
@synthesize lableHeight;
@synthesize lableWidth;


-(id)initWithDBResultSet:(FMResultSet *)findResultSet{
    if(findResultSet != nil){
        self = [super init];
        if(self){
            _tmpMallId = [findResultSet stringForColumn:@"mallId"];
            _tmpMerchantInstanceId = [findResultSet stringForColumn:@"merchantInstanceId"];
            _tmpMerchantInstanceName = [findResultSet stringForColumn:@"merchantInstanceName"];
            _tmpLatitude = [findResultSet doubleForColumn:@"latitude"];
            _tmpLongtitude = [findResultSet doubleForColumn:@"longtitude"];
            _tmpMinorAreaId = [findResultSet stringForColumn:@"minorAreaId"];
            _tmpMerchantInstanceName = [findResultSet stringForColumn:@"merchantInstanceName"];
            _tmpMajorAreaId = [findResultSet stringForColumn:@"majorAreaId"];
            _tmpFloorId = [findResultSet stringForColumn:@"floorId"];
            _tmpAddress = [findResultSet stringForColumn:@"address"];
            _tmpDisplayLevel = [findResultSet doubleForColumn:@"displayLevel"];
            _tmpLableHeight = [findResultSet doubleForColumn:@"labelHeight"];
            _tmpLableWidth = [findResultSet doubleForColumn:@"labelWidth"];
        }
    }
    return self;
    
}

-(id<YTMall>)mall{
    if(_tmpMall == nil){
        
        FMDatabase *db = [YTDBManager sharedManager];
        if([db open]){
            
            FMResultSet *result = [db executeQuery:@"select * from Mall where mallId = ?",_tmpMallId];
            [result next];
            
            _tmpMall = [[YTLocalMall alloc] initWithDBResultSet:result];
        }
    }
    return _tmpMall;
}

-(id<YTFloor>)floor{
    if(_tmpFloor == nil){
        
        FMDatabase *db = [YTDBManager sharedManager];
        if([db open]){
            
            FMResultSet *result = [db executeQuery:@"select * from Floor where floorId = ?",_tmpFloorId];
            [result next];
            
            _tmpFloor = [[YTLocalFloor alloc] initWithDBResultSet:result];
        }
    }
    return _tmpFloor;
}

-(NSString *)merchantLocationName{
    return _tmpMerchantInstanceName;
}

-(NSString *)identifier{
    return _tmpMerchantInstanceId;
}

-(CLLocationCoordinate2D )coordinate{
    return CLLocationCoordinate2DMake(_tmpLatitude, _tmpLongtitude);
}

-(NSNumber *)displayLevel{
    return [NSNumber numberWithFloat:_tmpDisplayLevel];
}

-(id<YTMajorArea>)majorArea{
    if(_tmpMajorArea == nil){
        
        FMDatabase *db = [YTDBManager sharedManager];
        if([db open]){
            
            FMResultSet *result = [db executeQuery:@"select * from MajorArea where majorAreaId = ?",_tmpMajorAreaId];
            [result next];
            
            _tmpMajorArea = [[YTLocalMajorArea alloc] initWithDBResultSet:result];
        }
    }
    return _tmpMajorArea;
}

-(id<YTMinorArea>)inMinorArea{
    
    if(_tmpMinorArea == nil){
        
        FMDatabase *db = [YTDBManager sharedManager];
        if([db open]){
            
            FMResultSet *result = [db executeQuery:@"select * from MinorArea where minorAreaId = ?",_tmpMinorAreaId];
            [result next];
            
            _tmpMinorArea = [[YTLocalMinorArea alloc] initWithDBResultSet:result];
        }
    }
    return _tmpMinorArea;
}

-(NSString *)address{
    return _tmpAddress;
}

-(float)lableWidth{
    return _tmpLableWidth;
}

-(float)lableHeight{
    return _tmpLableHeight;
}

-(void)getCloudThumbNailWithCallBack:(void (^)(UIImage *, NSError *))callback{
        AVQuery *query = [[AVQuery alloc] initWithClassName:@"Merchant"];
        [query whereKey:@"localDBId" equalTo:_tmpMerchantInstanceId];
        query.cachePolicy = kAVCachePolicyCacheElseNetwork;
        query.maxCacheAge = 24 * 3600;
    
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(objects.count <= 0 || error){
                callback(nil,error);
                return;
            }

        AVObject *specificMerchant = [objects objectAtIndex:0];
        AVFile *file = specificMerchant[@"Icon"];
        
        if (file != nil) {
            [file getThumbnail:YES width:100 height:100 withBlock:callback];
        }
        }];
   
    
}
-(void)getCloudMerchantTypeWithCallBack:(void (^)(NSArray *result,NSError *error))callback{
    AVQuery *query = [AVQuery queryWithClassName:@"Merchant"];
    [query whereKey:@"localDBId" equalTo:_tmpMerchantInstanceId];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (object == nil || error) {
            callback(nil,error);
            return ;
        }
        NSString *type = object[@"type"];
        callback([type componentsSeparatedByString:@" "],nil);
    }];
}

-(YTPoi *)producePoi{
    YTMerchantPoi *result = [[YTMerchantPoi alloc]  initWithMerchantInstance:self];
    return result;
}
@end
