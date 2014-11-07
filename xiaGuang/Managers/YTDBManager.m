//
//  YTDBManager.m
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTDBManager.h"

#import <AVOSCloud/AVOSCloud.h>

#define LOCALDB_VERION_KEY  @"YTLocalDBVersion"
#define BACKUPDB_VERSION_KEY    @"YTBackupDBVersion"

#define LOCALDB_FILE    @"highGuangDB"
#define BACKUPDB_FILE   @"highGuangDBSwap"

#define AVOS_DB_CLASS   @"DB"
#define AVOS_DB_VERSION_KEY @"version"
#define AVOS_DB_FILE_KEY      @"db"

@interface YTDBManager() {
    NSTimer *_timer;
    
    BOOL _hasNewDB;
    
    NSObject *_lock;
    
    NSString *_dir;
    
    NSString *_plistPath;
    NSString *_localDBPath;
    NSString *_backupDBPath;
    
}

- (void)checkAndDownload:(NSTimer *)timer;

@end

@implementation YTDBManager

+(id)sharedManager{
    static YTDBManager *dbInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbInstance = [[YTDBManager alloc] init];
    });
    return dbInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _dir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        
        _plistPath = [_dir stringByAppendingPathComponent:@"db.plist"];
        _localDBPath = [_dir stringByAppendingPathComponent:LOCALDB_FILE];
        _backupDBPath = [_dir stringByAppendingPathComponent:BACKUPDB_FILE];
        
        // copy resources from Bundle to Document directory
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSError *error;
        
        [fileManager createDirectoryAtPath:_dir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
        
        if (![fileManager fileExistsAtPath:_localDBPath]) {
            [fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:LOCALDB_FILE ofType:@""]
                                 toPath:_localDBPath
                                  error:&error];
        }
        
        if (![fileManager fileExistsAtPath:_plistPath]) {
            [fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"db" ofType:@"plist"]
                                 toPath:_plistPath
                                  error:&error];
        }
        
        _db = [[FMDatabase alloc] initWithPath:_localDBPath];
        _timer = nil;
        _hasNewDB = NO;
        _lock = [[NSObject alloc] init];
        
        
    }
    return self;
}

- (void)startBackgroundDownload {
    if (_timer == nil) {
        // check every hour
        _timer = [NSTimer scheduledTimerWithTimeInterval:3600
                                                  target:self
                                                selector:@selector(checkAndDownload:)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)stopBackgroundDownload {
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)checkAndSwitchToNewDB {
    @synchronized(_lock) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:_plistPath];
        
        int backupVersion = [dict[BACKUPDB_VERSION_KEY] intValue];
        
        if (backupVersion != 0) {
            // there's a new version. do the swap
            
            // First switch to new db
            _db = [[FMDatabase alloc] initWithPath:_backupDBPath];
            
            // Then delete the original file
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            
            [fileManager removeItemAtPath:_localDBPath error:&error];
            
            // Then copy new file to be the new local file
            [fileManager copyItemAtPath:_backupDBPath toPath:_localDBPath error:&error];
            
            // switch to new db
            _db = [[FMDatabase alloc] initWithPath:_localDBPath];
            
            // remove new db file
            [fileManager removeItemAtPath:_backupDBPath error:&error];
            
            // update plist
            dict[LOCALDB_VERION_KEY] = [NSNumber numberWithInt:backupVersion];
            [dict removeObjectForKey:BACKUPDB_VERSION_KEY];
            
            [dict writeToFile:_plistPath atomically:YES];
        }
    }
    
}

- (void)checkAndDownload:(NSTimer *)timer {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:_plistPath];
    
    int localVersion = [dict[LOCALDB_VERION_KEY] intValue];
    
    int backupVersion = [dict[BACKUPDB_VERSION_KEY] intValue];
    if (backupVersion == 0) {
        backupVersion = -INFINITY;
    }
    
    AVQuery *query = [AVQuery queryWithClassName:AVOS_DB_CLASS];
    [query orderByDescending:AVOS_DB_VERSION_KEY];
    query.limit = 1;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil && [objects count] > 0) {
            AVObject *obj = objects[0];
            
            int version = [obj[AVOS_DB_VERSION_KEY] intValue];
            
            if (version > localVersion && version > backupVersion) {
                
                AVFile *file = obj[AVOS_DB_FILE_KEY];
                
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (error == nil) {
                        
                        dict[BACKUPDB_VERSION_KEY] = [NSNumber numberWithInt:version];
                        
                        @synchronized(_lock) {
                            [data writeToFile:_backupDBPath atomically:YES];
                            [dict writeToFile:_plistPath atomically:YES];
                        }
                    }
                }];
            }
        }
    }];   
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
