//
//  YTUserDefaults.h
//  xiaGuang
//
//  Created by YunTop on 14/10/31.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface YTUserDefaults : NSObject
+(instancetype)standardUserDefaults;

-(void)setCoord:(CLLocationCoordinate2D)coord;
//no set Coord return MAXFLOAT;
-(CLLocationCoordinate2D)coord;
-(void)removeCoord;

-(void)setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key;
-(NSDictionary *)dictionaryWithKey:(NSString *)key;
-(void)removeDictionaryForKey:(NSString *)key;

//Key == nil return coord existence
-(BOOL)existenceOfTheKey:(NSString *)key;

@end
