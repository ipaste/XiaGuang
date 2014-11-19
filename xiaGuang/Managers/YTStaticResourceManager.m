//
//  YTStaticResourceManager.m
//  HighGuang
//
//  Created by Yuan Tao on 9/2/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTStaticResourceManager.h"

#import <AVOSCloud/AVOSCloud.h>
#import <FCFileManager.h>
#import <UnrarKit/URKArchive.h>t
#define LOCALDB_VERION_KEY  @"YTLocalDBVersion"
#define BACKUPDB_VERSION_KEY    @"YTBackupDBVersion"

#define LOCAL_STATIC_DATA_VERSION_KEY @"YTLocalStaticDataVersion"
#define BACKUP_STATIC_DATA_VERSION_KEY @"YTBackupStaticDataVersion"


#define LOCALDB_FILE    @"highGuangDB"
#define BACKUPDB_FILE   @"highGuangDBSwap"

#define AVOS_DB_CLASS   @"DB"
#define AVOS_DB_VERSION_KEY @"version"
#define AVOS_STATIC_VERSION_KEY @"version"

#define AVOS_DB_FILE_KEY      @"db"

#define AVOS_STATIC_DATA_KEY @"data"

#define RAR_PATH [FCFileManager pathForDocumentsDirectoryWithPath:@"data.rar"]
#define PLIST_PATH [FCFileManager pathForDocumentsDirectoryWithPath:@"static.plist"]
#define INSTRUCTION_PLIST [FCFileManager pathForDocumentsDirectoryWithPath:@"/static-staging/instruction.plist"]

#define STAGEING_DIR [FCFileManager pathForDocumentsDirectoryWithPath:@"/static-staging/"]
#define DATA_DIR [FCFileManager pathForDocumentsDirectoryWithPath:@"/static-data/"]

#define CURRENT_DIR [FCFileManager pathForDocumentsDirectoryWithPath:@"/current/"]
#define CURRENT_DATA_DIR [FCFileManager pathForDocumentsDirectoryWithPath:@"/current/data/"]
#define CURRENT_DATA_DB_PATH [FCFileManager pathForDocumentsDirectoryWithPath:@"/current/data/highGuangDB"]
#define CURRENT_MANIFEST_PATH [FCFileManager pathForDocumentsDirectoryWithPath:@"/current/manifest.plist"]

#define BUNDLE_DB_PATH [FCFileManager pathForMainBundleDirectoryWithPath:@"highGuangDB"]
#define BUNDLE_MANIFEST_PATH [FCFileManager pathForMainBundleDirectoryWithPath:@"manifest.plist"]

#define STAGING_DIR [FCFileManager pathForDocumentsDirectoryWithPath:@"/staging/"]
#define STAGING_DATA_DIR [FCFileManager pathForDocumentsDirectoryWithPath:@"/staging/data/"]
#define STAGING_DATA_DB_PATH [FCFileManager pathForDocumentsDirectoryWithPath:@"/staging/data/highGuangDB"]
#define STAGING_MANIFEST_PATH [FCFileManager pathForDocumentsDirectoryWithPath:@"/staging/manifest.plist"]

@interface YTStaticResourceManager() {
    NSTimer *_timer;
    
    BOOL _hasNewDB;
    
    NSObject *_lock;
    
    NSString *_dir;
    
    NSString *_plistPath;
    NSString *_localDBPath;
    NSString *_backupDBPath;
    
}

- (void)checkAndDownloadData:(NSTimer *)timer;

@end

@implementation YTStaticResourceManager

+(id)sharedManager{
    static YTStaticResourceManager *dbInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbInstance = [[YTStaticResourceManager alloc] init];
    });
    return dbInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSLog(@"%@",CURRENT_DIR);
        if(![FCFileManager existsItemAtPath:CURRENT_DIR]){
            [FCFileManager createDirectoriesForPath:CURRENT_DIR];
            [FCFileManager createDirectoriesForPath:CURRENT_DATA_DIR];
        }
        
        if(![FCFileManager existsItemAtPath:CURRENT_MANIFEST_PATH]){
            
            [FCFileManager copyItemAtPath:BUNDLE_MANIFEST_PATH toPath:CURRENT_MANIFEST_PATH];
        }
        
        [self pullInBundleDataInManifestIfNeeded];
        /*
        if (![fileManager fileExistsAtPath:PLIST_PATH]) {
            [fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"static" ofType:@"plist"]
                                 toPath:PLIST_PATH
                                  error:&error];
        }
        
        
        _db = [[FMDatabase alloc] initWithPath:_localDBPath];
        _timer = nil;
        _hasNewDB = NO;
        _lock = [[NSObject alloc] init];
        */
        
    }
    return self;
}

-(void)pullInBundleDataInManifestIfNeeded{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:CURRENT_MANIFEST_PATH];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([key isEqualToString:@"db"]){
            
            if(![FCFileManager existsItemAtPath:CURRENT_DATA_DB_PATH]){
                NSLog(@"%@",BUNDLE_DB_PATH);
                [FCFileManager copyItemAtPath:BUNDLE_DB_PATH toPath:CURRENT_DATA_DB_PATH];
            }
            
        }
        else if([key isEqualToString:@"version"]){
            //skip version
        }
        
        else
        {
            
        
            NSString *fileName = key;
            NSString *targetMapPath = [NSString stringWithFormat:@"%@/%@.mbtiles",CURRENT_DATA_DIR,fileName];
            NSString *fromMapPath = [NSString stringWithFormat:@"%@/%@.mbtiles",[FCFileManager pathForMainBundleDirectory],fileName];
            if(![FCFileManager existsItemAtPath:targetMapPath]){
                
                [FCFileManager copyItemAtPath:fromMapPath toPath:targetMapPath];
            
            }
            
        }
    }];

}



- (void)startBackgroundDownload {
    if (_timer == nil) {
        // check every hour
        _timer = [NSTimer scheduledTimerWithTimeInterval:60
                                                  target:self
                                                selector:@selector(checkAndDownloadData:)
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



- (void)checkAndSwitchToNewStaticData {
    @synchronized(_lock) {
        
        if(![FCFileManager isDirectoryItemAtPath:STAGEING_DIR] || ![FCFileManager existsItemAtPath:STAGEING_DIR]){
            //if staging is present then return
            return;
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
        
        int backupVersion = [dict[BACKUP_STATIC_DATA_VERSION_KEY] intValue];
        
        if (backupVersion != 0) {
            // there's a new version. do the swap
            
            [self extractFiles];
            [self updateAndRemoveMaps];
            [self releaseNewDB];
            
            // update plist
            dict[LOCAL_STATIC_DATA_VERSION_KEY] = [NSNumber numberWithInt:backupVersion];
            [dict removeObjectForKey:BACKUP_STATIC_DATA_VERSION_KEY];
            
            [dict writeToFile:PLIST_PATH atomically:YES];
        }
        
        
        NSArray *stagingdata = [FCFileManager listFilesInDirectoryAtPath:STAGEING_DIR];
        
        [FCFileManager listFilesInDirectoryAtPath:DATA_DIR];
    }
    
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)checkAndDownloadData:(NSTimer *)timer{
    
    if([FCFileManager isDirectoryItemAtPath:STAGEING_DIR]){
        //if staging is present then return
        return;
    }
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:CURRENT_MANIFEST_PATH];
    
    int localVersion = [dict[@"version"] intValue];
    
    AVQuery *query = [AVQuery queryWithClassName:@"StaticData"];
    [query orderByDescending:AVOS_STATIC_VERSION_KEY];
    query.limit = 1;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil && [objects count] > 0) {
            AVObject *obj = objects[0];
            
            int version = [obj[AVOS_STATIC_VERSION_KEY] intValue];
            
            if (version > localVersion) {
                
                AVFile *file = obj[AVOS_STATIC_DATA_KEY];
                
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (error == nil) {
                        
                        dict[@"version"] = [NSNumber numberWithInt:version];
                        
                        @synchronized(_lock) {
                            
                            [self createStagingArea];
                            
                            [data writeToFile:STAGING_MANIFEST_PATH atomically:YES];
                            
                            
                        }
                    }
                }];
            }
        }
    }];
}

-(void)createStagingArea{
    
    if([FCFileManager existsItemAtPath:STAGING_DIR]){
        [FCFileManager removeItemAtPath:STAGING_DIR];
    }
    [FCFileManager createDirectoriesForPath:STAGEING_DIR];
    [FCFileManager createDirectoriesForPath:STAGING_DATA_DIR];
}

-(void)compareAndDownload{
    NSMutableDictionary *currentManifest = [[NSMutableDictionary alloc] initWithContentsOfFile:CURRENT_MANIFEST_PATH];
    NSMutableDictionary *const = [[NSMutableDictionary alloc] initWithContentsOfFile:STAGING_MANIFEST_PATH];
}

-(BOOL)extractFiles{
    
    URKArchive *archiver = [URKArchive rarArchiveAtPath:RAR_PATH];
    [FCFileManager removeItemsInDirectoryAtPath:STAGEING_DIR];
    
    NSError *err;
    BOOL extractResult = [archiver extractFilesTo:STAGEING_DIR overWrite:YES error:&err];
    if(!extractResult || err != nil){
        NSLog(@"shit");
        return false;
    }
    
    return true;
    
}

-(void)updateAndRemoveMaps{
    NSMutableDictionary *instructionDict = [[NSMutableDictionary alloc] initWithContentsOfFile:INSTRUCTION_PLIST];
    NSArray *update = [instructionDict objectForKey:@"update"];
    NSArray *remove = [instructionDict objectForKey:@"remove"];
    
    for(NSString *filename in update){
        NSString *fromPath = [NSString stringWithFormat:@"%@%@",STAGEING_DIR,filename];
        NSString *toPath = [NSString stringWithFormat:@"%@%@",DATA_DIR,filename];
        [FCFileManager copyItemAtPath:fromPath toPath:toPath];
    }
    
    
    for(NSString *toRemove in remove){
        NSString *toRemovePath = [NSString stringWithFormat:@"%@%@",DATA_DIR,toRemove];
        [FCFileManager removeItemAtPath:toRemove];
    }
}

-(void)releaseNewDB{
    NSString *stagingDBPath = [NSString stringWithFormat:@"%@%@",STAGEING_DIR,@"highGuangDB"];
    if([FCFileManager existsItemAtPath:stagingDBPath]){
        _db = [[FMDatabase alloc] initWithPath:stagingDBPath];
        [FCFileManager removeItemAtPath:_localDBPath];
        [FCFileManager copyItemAtPath:stagingDBPath toPath:_localDBPath];
        _db = [[FMDatabase alloc] initWithPath:_localDBPath];
    }
    
}



@end
