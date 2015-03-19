//
//  YTStaticResourceDownloader.m
//  虾逛
//
//  Created by Yuan Tao on 11/27/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTStaticResourceDownloader.h"
#import "AppDelegate.h"

#define STAGING_DATA_DB_PATH [FCFileManager pathForDocumentsDirectoryWithPath:@"/staging/data/highGuangDB"]
#define STAGING_UPDATE_TABLE [FCFileManager pathForDocumentsDirectoryWithPath:@"/staging/update.plist"]

#define STAGING_DATA_DIR [FCFileManager pathForDocumentsDirectoryWithPath:@"/staging/data/"]
#define STAGING_FAIL_TABLE [FCFileManager pathForDocumentsDirectoryWithPath:@"/staging/fail.plist"]

@implementation YTStaticResourceDownloader{
    NSObject *_downloadProgress;
    NSObject *_failTableLock;
    NSObject *_updateTableLock;
}

+(id)sharedDownloader{
    static YTStaticResourceDownloader *downloaderInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloaderInstance = [[YTStaticResourceDownloader alloc] init];
    });
    return downloaderInstance;
}


-(id)init{
    self = [super init];
    if(self){
        _downloadProgress = [[NSObject alloc] init];
        _failTableLock = [[NSObject alloc] init];
        _updateTableLock = [[NSObject alloc] init];
    }
    return self;
}

-(void)startDownloadingDBVersion:(int)version{
    AVQuery *queryForDB = [AVQuery queryWithClassName:@"DB"];
    [queryForDB whereKey:@"version" equalTo:[NSNumber numberWithInt:version]];
    [queryForDB getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error1) {
        if(error1 != nil){
            NSLog(@"couldn't get db object");
            [self createFailRecordForKey:@"db" andVersion:version];
            return;
        }
        AVFile *db = object[@"db"];
        [db getDataInBackgroundWithBlock:^(NSData *data, NSError *error2) {
            if(error2 != nil){
                [self createFailRecordForKey:@"db" andVersion:version];
                return;
            }
            @synchronized(_updateTableLock){
                
                [data writeToFile:STAGING_DATA_DB_PATH atomically:YES];
                NSMutableDictionary *update = [[NSMutableDictionary alloc] initWithContentsOfFile:STAGING_UPDATE_TABLE];
                if([update objectForKey:@"db"] == nil){
                    NSLog(@"some crazy thing happens");
                }
                [update removeObjectForKey:@"db"];
                [update writeToFile:STAGING_UPDATE_TABLE atomically:YES];
                if([FCFileManager existsItemAtPath:STAGING_FAIL_TABLE]){
                    [self removeFailRecordForKey:@"db"];
                }
           
            }
            
        }];
    }];
}


-(void)startDownloadingMapsInUpdateTable{
    @synchronized(_updateTableLock){
        
        NSMutableDictionary *updateTable = [[NSMutableDictionary alloc] initWithContentsOfFile:STAGING_UPDATE_TABLE];
        
        [self startDownloadingMapsInTable:updateTable];
    }

}


-(void)startDownloadingMapsInFailTable{
    @synchronized(_failTableLock){
        
        NSMutableDictionary *failTable = [[NSMutableDictionary alloc] initWithContentsOfFile:STAGING_FAIL_TABLE];
        
        [self startDownloadingMapsInTable:failTable];
    }
    
}

-(void)startDownloadingMapsInTable:(NSDictionary *)table{
    
    NSMutableArray *queries = [NSMutableArray array];
    
    for(NSString *key in table.allKeys){
        AVQuery *subquery = [[AVQuery alloc]initWithClassName:@"Map"];
        if([key isEqualToString:@"db"]){
            continue;
        }
        
        [subquery whereKey:@"version" equalTo:[table objectForKey:key]];
        [subquery whereKey:@"mapName" equalTo:key];
        [queries addObject:subquery];
    }
    if(queries.count == 0){
        //handle it here
        return;
    }
    
    
    AVQuery *or = [AVQuery orQueryWithSubqueries:queries];
    [or findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *err) {
        if(err != nil){
            NSLog(@"or fails");
            
            for(NSString *key in table.allKeys){
                if([key isEqualToString:@"db"]){
                    continue;
                }
                [self createFailRecordForKey:key andVersion:[[table objectForKey:key] integerValue]];
            }
            
            return;
        }
        for(AVObject *tmp in objects){
            AVFile *map = tmp[@"map"];
            [map getDataInBackgroundWithBlock:^(NSData *data, NSError *err2) {
                if(err2 != nil){
                    NSLog(@"download map data fails");
                    NSString *failKey = tmp[@"mapName"];
                    [self createFailRecordForKey:failKey andVersion:[[table objectForKey:failKey] integerValue]];
                    return;
                }
                
                
                @synchronized(_updateTableLock){
                    [data writeToFile:[NSString stringWithFormat:@"%@/%@.mbtiles",STAGING_DATA_DIR,tmp[@"mapName"]] atomically:YES];
                    NSMutableDictionary *update = [[NSMutableDictionary alloc] initWithContentsOfFile:STAGING_UPDATE_TABLE];
                    if([update objectForKey:tmp[@"mapName"]] == nil){
                        NSLog(@"some crazy thing happens");
                    }
                    [update removeObjectForKey:tmp[@"mapName"]];
                    [update writeToFile:STAGING_UPDATE_TABLE atomically:YES];
                    if([FCFileManager existsItemAtPath:STAGING_FAIL_TABLE]){
                        [self removeFailRecordForKey:tmp[@"mapName"]];
                    }
                   
                }
            }];
        }

    }];
}

-(void)createFailRecordForKey:(NSString *)key
                   andVersion:(int)version{
    @synchronized(_failTableLock){
        NSMutableDictionary *failTable;
        if([FCFileManager existsItemAtPath:STAGING_FAIL_TABLE]){
            failTable = [[NSMutableDictionary alloc] initWithContentsOfFile:STAGING_FAIL_TABLE];
        }
        else{
            failTable = [[NSMutableDictionary alloc] init];
        }
        [failTable setObject:[NSNumber numberWithInt:version] forKey:key];
        [failTable writeToFile:STAGING_FAIL_TABLE atomically:YES];
    }
}

-(void)removeFailRecordForKey:(NSString *)key
{
    @synchronized(_failTableLock){
        if(![FCFileManager existsItemAtPath:STAGING_FAIL_TABLE]){
            return;
        }
        NSMutableDictionary *failTable = [[NSMutableDictionary alloc] initWithContentsOfFile:STAGING_FAIL_TABLE];
        if([failTable objectForKey:key] != nil){
            [failTable removeObjectForKey:key];
        }
        [failTable writeToFile:STAGING_FAIL_TABLE atomically:YES];
    }
    
}

@end
