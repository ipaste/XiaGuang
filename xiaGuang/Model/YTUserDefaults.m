//
//  YTUserDefaults.m
//  xiaGuang
//
//  Created by YunTop on 14/10/31.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTUserDefaults.h"

@implementation YTUserDefaults{
    NSUserDefaults *_userDefaults;
}
+(instancetype)standardUserDefaults{
    static YTUserDefaults *userDefaults;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userDefaults = [[YTUserDefaults alloc]init];
    });
    return userDefaults;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}
-(void)setCoord:(CLLocationCoordinate2D)coord{
    float latitude = coord.latitude;
    float longitude = coord.longitude;
    [_userDefaults setFloat:latitude forKey:@"latitude"];
    [_userDefaults setFloat:longitude forKey:@"longitude"];
    [_userDefaults setBool:YES forKey:@"mark"];
    [_userDefaults synchronize];
}

-(CLLocationCoordinate2D)coord{

    float latitude = [_userDefaults floatForKey:@"latitude"];
    float longitude = [_userDefaults floatForKey:@"longitude"];
    BOOL marked =  [_userDefaults boolForKey:@"mark"];
    if (!marked) {
        return CLLocationCoordinate2DMake(MAXFLOAT, MAXFLOAT);
    }
    return CLLocationCoordinate2DMake(latitude, longitude);
}

-(void)removeCoord{
    [_userDefaults removeObjectForKey:@"latitude"];
    [_userDefaults removeObjectForKey:@"longitude"];
    [_userDefaults setBool:NO forKey:@"mark"];
    [_userDefaults synchronize];
}

-(void)setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key{
    [_userDefaults setObject:dictionary forKey:key];
}

-(NSDictionary *)dictionaryWithKey:(NSString *)key{
    return [_userDefaults objectForKey:key];
}
@end
