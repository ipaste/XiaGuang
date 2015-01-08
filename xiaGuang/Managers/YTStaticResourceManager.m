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
#import <UnrarKit/URKArchive.h>
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


#define STAGING_UPDATE_TABLE [FCFileManager pathForDocumentsDirectoryWithPath:@"/staging/update.plist"]
#define STAGING_DELETE_TABLE [FCFileManager pathForDocumentsDirectoryWithPath:@"/staging/delete.plist"]


#define STAGING_FAIL_TABLE [FCFileManager pathForDocumentsDirectoryWithPath:@"/staging/fail.plist"]
@interface YTStaticResourceManager() {
    NSTimer *_timer;
    
    YTStaticResourceDownloader *_downloader;
    
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
        _timer = nil;
        _db = [[FMDatabase alloc] initWithPath:CURRENT_DATA_DB_PATH];
        
        _downloader = [YTStaticResourceDownloader sharedDownloader];
        
    }
    return self;
}

-(void)pullInBundleDataInManifestIfNeeded{
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:CURRENT_DIR]];
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
        _timer = [NSTimer scheduledTimerWithTimeInterval:10*60
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



- (void)checkAndSwitchToNewStaticData {
        
        if(![FCFileManager existsItemAtPath:STAGING_UPDATE_TABLE]){
            return;
        }
        NSMutableDictionary *update = [[NSMutableDictionary alloc] initWithContentsOfFile:STAGING_UPDATE_TABLE];
        if(update.count > 0){
            NSLog(@"download not done");
            return;
        }
        
        
        NSMutableDictionary *curDict = [[NSMutableDictionary alloc] initWithContentsOfFile:CURRENT_MANIFEST_PATH];
        NSMutableDictionary *stagingDict = [[NSMutableDictionary alloc] initWithContentsOfFile:STAGING_MANIFEST_PATH];
        
        NSDictionary *updateTable = [self toUpdateToGetManifest1:stagingDict fromManifest2:curDict];
        NSArray *deleteTable = [self toDeleteToGetManifest1:stagingDict fromManifest2:curDict];
        
        NSArray *currentfiles = [FCFileManager listFilesInDirectoryAtPath:CURRENT_DATA_DIR];
        for(NSString *filename in currentfiles){
            
            if([filename rangeOfString:@"highGuangDB"].length>0){
                if([updateTable objectForKey:@"db"] == nil){
                    [FCFileManager copyItemAtPath:CURRENT_DATA_DB_PATH toPath:STAGING_DATA_DB_PATH];
                }
                continue;
            }
            NSString *mapPath = [filename substringToIndex:filename.length-@".mbtiles".length];
            NSArray *paths = [mapPath pathComponents];
            NSString *mapName = paths[paths.count-1];
            if([updateTable objectForKey:mapName] != nil || [deleteTable containsObject:mapName]){
                continue;
            }
            
            [FCFileManager copyItemAtPath:filename toPath:[NSString stringWithFormat:@"%@/%@.mbtiles",STAGING_DATA_DIR,mapName]];
        }
        
        [self theGreatMigrate];
    
    
}

-(void)theGreatMigrate{
    _db = [[FMDatabase alloc] initWithPath:STAGING_DATA_DB_PATH];
    [FCFileManager removeItemAtPath:CURRENT_DIR];
    [FCFileManager copyItemAtPath:STAGING_DIR toPath:CURRENT_DIR];
    _db = [[FMDatabase alloc] initWithPath:CURRENT_DATA_DB_PATH];
    [FCFileManager removeItemAtPath:STAGING_DIR];
    [FCFileManager removeItemAtPath:[NSString stringWithFormat:@"%@/delete.plist",CURRENT_DIR]];
    [FCFileManager removeItemAtPath:[NSString stringWithFormat:@"%@/update.plist",CURRENT_DIR]];
    [FCFileManager removeItemAtPath:[NSString stringWithFormat:@"%@/fail.plist",CURRENT_DIR]];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)checkAndDownloadData:(NSTimer *)timer{
    
    if([FCFileManager existsItemAtPath:STAGING_FAIL_TABLE]){
        
        NSMutableDictionary *failTable = [[NSMutableDictionary alloc] initWithContentsOfFile:STAGING_FAIL_TABLE];
        
        if(failTable.count>0){
            if([failTable objectForKey:@"db"] != nil){
                [_downloader startDownloadingDBVersion:[[failTable objectForKey:@"db"] integerValue]];
            }
            [_downloader startDownloadingMapsInFailTable];
        }
        return;
    }
    
    if([FCFileManager isDirectoryItemAtPath:STAGING_DIR]){
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
                    
                        [self createStagingArea];
                        
                        [data writeToFile:STAGING_MANIFEST_PATH atomically:YES];
                        
                        
                        NSMutableDictionary *curDict = [[NSMutableDictionary alloc] initWithContentsOfFile:CURRENT_MANIFEST_PATH];
                        NSMutableDictionary *stagingDict = [[NSMutableDictionary alloc] initWithContentsOfFile:STAGING_MANIFEST_PATH];
                            
                        NSDictionary *updateTable = [self toUpdateToGetManifest1:stagingDict fromManifest2:curDict];
                        NSArray *deleteTable = [self toDeleteToGetManifest1:stagingDict fromManifest2:curDict];
                        [updateTable writeToFile:STAGING_UPDATE_TABLE atomically:YES];
                        [deleteTable writeToFile:STAGING_DELETE_TABLE atomically:YES];
                        
                            
                        if([updateTable objectForKey:@"db"] != nil){
                            [_downloader startDownloadingDBVersion:[[updateTable objectForKey:@"db"] integerValue]];
                        }
                        
                        [_downloader startDownloadingMapsInUpdateTable];
                    }
                }];
            }
        }
    }];
}



-(void)createStagingArea{
    
    
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:STAGING_DIR]];
    if([FCFileManager existsItemAtPath:STAGING_DIR]){
        [FCFileManager removeItemAtPath:STAGING_DIR];
    }
    [FCFileManager createDirectoriesForPath:STAGING_DIR];
    [FCFileManager createDirectoriesForPath:STAGING_DATA_DIR];
}

-(NSDictionary *)toUpdateToGetManifest1:(NSMutableDictionary *)dict1
                     fromManifest2:(NSMutableDictionary *)dict2{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for(NSString *key in dict1.allKeys){
        if([key isEqualToString:@"version"]){
            continue;
        }
        
        if([key isEqualToString:@"db"]){
            int toDBVersion = [[dict1 objectForKey:key] integerValue];
            int fromDBVersion = [[dict2 objectForKey:key] integerValue];
            if(toDBVersion != fromDBVersion){
                [result setObject:[NSNumber numberWithInt:toDBVersion] forKey:@"db"];
            }
            continue;
        }
        int tmpVersion = [[dict1 objectForKey:key] integerValue];
        
        
        if([dict2 objectForKey:key] == nil ){
            [result setObject:[NSNumber numberWithInt:tmpVersion] forKey:key];
            continue;
        }
        
        int tmpVersion2 = [[dict2 objectForKey:key] integerValue];
        if(tmpVersion != tmpVersion2){
            [result setObject:[NSNumber numberWithInt:tmpVersion] forKey:key];
        }
    }
    return result;
    
}

-(NSArray *)toDeleteToGetManifest1:(NSMutableDictionary *)dict1
                     fromManifest2:(NSMutableDictionary *)dict2{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(NSString *key in dict2.allKeys){
        if([dict1 objectForKey:key] == nil){
            [result addObject:key];
        }
    }
    return result;
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
