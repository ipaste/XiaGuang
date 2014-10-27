//
//  YTFileManager.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-15.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTFileManager : NSObject
+(id)defaultManager;
-(BOOL)fileExistsWithFileName:(NSString *)name;
-(id)readDataWithFileName:(NSString *)name;
-(BOOL)saveWithData:(id<NSCoding>)data andCreateFileName:(NSString *)name;
@end
