//
//  YTFileManager.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-15.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTFileManager.h"
@interface YTFileManager (){
    NSString *_path;
}
@end
@implementation YTFileManager
+(id)defaultManager{
    static YTFileManager *fileManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileManager = [[self alloc]init];
        
    });
    return fileManager;
}
-(id)init{
    self = [super init];
    if (self) {
        _path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    }
    return self;
}

-(BOOL)fileExistsWithFileName:(NSString *)name{
    NSString *path  = [_path stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}

-(id)readDataWithFileName:(NSString *)name{
     NSString *path  = [_path stringByAppendingPathComponent:name];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

-(BOOL)saveWithData:(id<NSCoding>)data andCreateFileName:(NSString *)name{
    if (data == nil || name == nil ) {
        return NO;
    }
    NSString *path  = [_path stringByAppendingPathComponent:name];
    [NSKeyedArchiver archiveRootObject:data toFile:path];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:path]];
        return YES;
    }
    return NO;
}

-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)url{
    assert([[NSFileManager defaultManager] fileExistsAtPath:[url path]]);
    NSError *error = nil;
    BOOL success = [url setResourceValue:[NSNumber numberWithBool:true] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        NSLog(@"错误信息:%@",error);
    }
    return success;
}
@end
