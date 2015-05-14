//
//  YTDataManager.m
//  虾逛
//
//  Created by Silence on 15/4/16.
//  Copyright (c) 2015年 Silence. All rights reserved.
//

#import "YTDataManager.h"
#import "YTMallDict.h"
#import "YTCloudMerchant.h"
#define DEVICE_IDENTIFIER [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#define DEVICE_NAME [UIDevice currentDevice].name
#define DOCUMENT_PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject
#define CACHES_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true).firstObject
#define USER_PATH [DOCUMENT_PATH stringByAppendingPathComponent:@".user"]
#define MAP_PATH [DOCUMENT_PATH stringByAppendingPathComponent:@".map"]
#define MAPPATH_PATH [DOCUMENT_PATH stringByAppendingPathComponent:@".path"]
#define DB_PATH [USER_PATH stringByAppendingPathComponent:@"highGuangDB"]
#define USERDB_PATH [USER_PATH stringByAppendingPathComponent:@"_user"]
#define MAX_FILESIZE 500

NSString *const KWifiNetworkKey= @"WIFI";
NSString *const KWwanNetworkKey = @"2G/3G/4G";
NSString *const KNoNetworkKey = @"No Network";
NSString *const kUploadKey = @"DataUpload";
NSString *const kRegionUpdate = @"regionDate";

/**
 *  更换数据库密码，使用正确的密码打开数据，然后再用ResetKey去修改
 */
NSString *const kDatabasePassword = @"WQNMLGDSBCNM";
NSString *const kYTMapDownloadConfigDone = @"mapDownloadConfigDone";
@interface YTDataManager(){
    Reachability *_reachability;
    NetworkStatus _currentNetworkStatus;
    FMDatabase *_tmpDatabase;
    FMDatabase *_userDatabase;
    FMDatabaseQueue *_queue;
    NSFileManager *_fileManager;
    NSUserDefaults *_userDefaults;
    NSString *_date;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)url;
@end

@implementation YTDataManager

- (FMDatabase *)database {
    return _tmpDatabase;
}

- (NSString *)mapPath{
    return MAPPATH_PATH;
}

- (NSString *)documentMapPath {
    return MAP_PATH;
}

- (NSString *)date{
    return _date;
}

+ (instancetype)defaultDataManager{
    static YTDataManager *dataManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[YTDataManager alloc]init];
    });
    return dataManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        _date = [formatter stringFromDate:date];
        
        // Network Status
        _reachability = [Reachability reachabilityWithHostname:@"www.leancloud.cn"];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
        [_reachability startNotifier];
        
        BOOL isConfig = false;
        _userDefaults = [NSUserDefaults standardUserDefaults];
        
        _fileManager = [NSFileManager defaultManager];
        if (![_fileManager fileExistsAtPath:USER_PATH]) {
            [_fileManager createDirectoryAtPath:USER_PATH withIntermediateDirectories:true attributes:nil error:nil];
            NSString *bundleDB = [[NSBundle mainBundle]pathForAuxiliaryExecutable:@"highGuangDB"];
            [_fileManager copyItemAtPath:bundleDB toPath:DB_PATH error:nil];
            isConfig = true;
        }
        
        if (![_fileManager fileExistsAtPath:MAP_PATH]) {
            [_fileManager createDirectoryAtPath:MAP_PATH withIntermediateDirectories:true attributes:nil error:nil];
        }
        
        if (![_fileManager fileExistsAtPath:MAPPATH_PATH]) {
            [_fileManager createDirectoryAtPath:MAPPATH_PATH withIntermediateDirectories:true attributes:nil error:nil];
        }
        
        _tmpDatabase = [FMDatabase databaseWithPath:DB_PATH];
        _userDatabase = [FMDatabase databaseWithPath:USERDB_PATH];
        _queue = [FMDatabaseQueue databaseQueueWithPath:DB_PATH];
        
        [_tmpDatabase open];
        [_userDatabase open];
        
        // 设置数据库密码
        // [_tmpDatabase setKey:kDatabasePassword];
        [_userDatabase setKey:kDatabasePassword];
        
        if (isConfig) {
            NSOperation *config = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(firstConfig) object:nil];
            [config start];
        }
        
        double fileSize = [[_fileManager attributesOfItemAtPath:USERDB_PATH error:nil] fileSize] / 1024;
        
        if (_reachability.currentReachabilityStatus == ReachableViaWiFi || fileSize < MAX_FILESIZE) {
            [self checkWhetherTheDataNeedsToBeUpload];
        }
        
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:MAP_PATH]];
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:MAPPATH_PATH]];
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:DB_PATH]];
    }
    return self;
}

- (void)closeAllDatebase{
    [_tmpDatabase close];
    [_userDatabase close];
}


- (void)updateCloudData{
    AVQuery *regionQuery = [AVQuery queryWithClassName:@"Region"];
    [regionQuery includeKey:@"city"];
    [regionQuery whereKey:@"ready" equalTo:@YES];
    [regionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil && objects != nil) {
            for (AVObject *object in objects) {
                NSInteger isExtension = [object[@"isExistence"] integerValue];
                NSNumber *uniId = object[@"uniId"];
                NSString *name = object[@"regionName"];
                NSNumber *cityId = object[@"city"][@"uniId"];
                FMResultSet *result = [_tmpDatabase executeQuery:@"SELECT isExistence FROM Region WHERE identify = ?",uniId];
                if ([result next]) {
                    if (isExtension != [result intForColumn:@"isExistence"]) {
                        [_tmpDatabase executeUpdate:@"UPDATE Region SET isExistence = ? WHERE identify = ?",[NSNumber numberWithInteger:isExtension],uniId];
                    }
                }else{
                    [_tmpDatabase executeUpdate:@"INSERT INTO Region('identify','name','city','isExistence') VALUES(?,?,?,?)",uniId,name,cityId,[NSNumber numberWithInteger:isExtension]];
                }
            }
        }

    }];
}

- (void)checkWhetherTheDataNeedsToBeUpload{
    if (![_userDefaults valueForKey:kUploadKey]) {
        [_userDefaults setValue:_date forKey:kUploadKey];
        [_userDefaults synchronize];
    }else{ 
        NSString *oldDate = [_userDefaults valueForKey:kUploadKey];
        if (![oldDate isEqualToString:_date]) {
            AVFile *userFile = [AVFile fileWithName:[NSString stringWithFormat:@"%@",_date] contentsAtPath:USERDB_PATH];
            AVObject *object = [AVObject objectWithClassName:@"UserInfo"];
            object[@"file"] = userFile;
            object[@"ifa"] = DEVICE_IDENTIFIER;
            object[@"deviceName"] = DEVICE_NAME;
            [object saveInBackground];
            [_userDefaults setValue:_date forKey:kUploadKey];
            [_userDefaults synchronize];
        }
    }
}

- (void)downloadedData:(NSData *)data dataName:(NSString *)name{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *dataFile = [CACHES_PATH stringByAppendingPathComponent:name];
        [self unZipWithData:data path:[NSURL fileURLWithPath:dataFile]];
        NSArray *subPath = [_fileManager subpathsAtPath:dataFile];
        for (NSString *path in subPath) {
            if ([path hasSuffix:@"csv"]) {
                if ([path hasPrefix:@"N_"]) {
                    [_fileManager copyItemAtPath:[dataFile stringByAppendingPathComponent:path]  toPath:[MAPPATH_PATH stringByAppendingPathComponent:path] error:nil];
                }else{
                    [self updateXiaGuangDatabaseWithCsvPath:[dataFile stringByAppendingPathComponent:path]];
                }
            }else{
                [_fileManager copyItemAtPath:[dataFile stringByAppendingPathComponent:path] toPath:[MAP_PATH stringByAppendingPathComponent:path] error:nil];
            }
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:kYTMapDownloadConfigDone object:nil userInfo:nil];
    });
}


- (void)unZipWithData:(NSData *)data path:(NSURL *)url{
    ZZArchive *sourceArchive = [ZZArchive archiveWithData:data error:nil];
    for (ZZArchiveEntry *entry in sourceArchive.entries) {
        NSURL *targetPath = [url URLByAppendingPathComponent:entry.fileName];
        if (![entry.fileName hasPrefix:@"__MACOSX"] ) {
            if (entry.fileMode & S_IFDIR) {
                [_fileManager createDirectoryAtURL:targetPath withIntermediateDirectories:true attributes:nil error:nil];
            }else{
                [_fileManager createDirectoryAtURL:[targetPath URLByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:nil];
                [[entry newDataWithError:nil] writeToURL:targetPath atomically:false];
            }
        }
    }
}

- (void)updateXiaGuangDatabaseWithCsvPath:(NSString *)path{
    NSString *tableName = [[path lastPathComponent] stringByDeletingPathExtension];
        
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (content == nil){
        content = [NSString stringWithContentsOfFile:path encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000) error:nil];
        content = [content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if(content == nil) {
            return;
        }
    }
    
    content = [content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *contents = [NSMutableArray arrayWithArray:[content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];

    if (contents.count > 1) {
        NSArray *fields = [contents.firstObject componentsSeparatedByString:@","];
        [contents removeObjectAtIndex:0];
        [_queue inDatabase:^(FMDatabase *db) {
            [YTHandleCsv saveData:_tmpDatabase tableName:tableName fields:fields datas:contents.copy];
        }];
    }
}




#pragma mark
#pragma mark 网络状态
- (void)networkStatusChanged:(NSNotification *)notification{
    NetworkStatus status = _reachability.currentReachabilityStatus;
    YTNetworkSatus networkStatus = YTNetworkSatusNotNomal;
    if (_userDatabase) {
        NSString *statusString = nil;
        NSNumber *count = nil;
        switch (status) {
            case ReachableViaWiFi:
            {
                //WIFI
                statusString = KWifiNetworkKey;
                FMResultSet *result = [_userDatabase executeQueryWithFormat:@"SELECT * FROM NetworkInfo WHERE status = %@",statusString];
                if ([result next]) {
                    count = [NSNumber numberWithInt:[result intForColumn:@"count"] + 1];
                }
                networkStatus = YTNetworkSatusWifi;
            }
                break;
            case ReachableViaWWAN:
            {
                //WWAN
                statusString = KWwanNetworkKey;
                FMResultSet *result = [_userDatabase executeQueryWithFormat:@"SELECT * FROM NetworkInfo WHERE status = %@",statusString];
                if ([result next]) {
                    count = [NSNumber numberWithInt:[result intForColumn:@"count"] + 1];
                }
                networkStatus = YTNetworkSatusWWAN;
            }
                break;
            case NotReachable:
            {
                //NO NETWORK
                statusString = KNoNetworkKey;
                FMResultSet *result = [_userDatabase executeQueryWithFormat:@"SELECT * FROM NetworkInfo WHERE status = %@",statusString];
                if ([result next]) {
                    count = [NSNumber numberWithInt:[result intForColumn:@"count"] + 1];
                }
                networkStatus = YTNetworkSatusNotNomal;
            }
                break;
        }
        [_userDatabase executeUpdateWithFormat:@"UPDATE NetworkInfo SET count = %@ WHERE status = %@",count,statusString];
        if ([_delegate respondsToSelector:@selector(networkStatusChanged:)]) {
            [_delegate networkStatusChanged:networkStatus];
        }
    }
}

- (void)refreshNetWorkState{
    YTNetworkSatus networkState = [self currentNetworkStatus];
    if ([_delegate respondsToSelector:@selector(networkStatusChanged:)]) {
        [_delegate networkStatusChanged:networkState];
    }
}

- (YTNetworkSatus)currentNetworkStatus{
    YTNetworkSatus networkStatus = YTNetworkSatusNotNomal;
    NetworkStatus status = _reachability.currentReachabilityStatus;
    switch (status) {
        case ReachableViaWWAN:
            networkStatus = YTNetworkSatusWWAN;
            break;
        case ReachableViaWiFi:
            networkStatus = YTNetworkSatusWifi;
            break;
        case NotReachable:
            networkStatus = YTNetworkSatusNotNomal;
    }
    return networkStatus;
}

#pragma mark
#pragma mark 首次配置
- (void)firstConfig {
    NSString *sql = @"CREATE TABLE MallInfo('identify' INTEGER NOT NULL PRIMARY KEY,'name' TEXT,'count' INTERGER)";
    [_userDatabase executeUpdate:sql];
    
    sql = @"CREATE TABLE MerchantInfo('identify' INTEGER NOT NULL PRIMARY KEY,'name' TEXT,'count' INTERGER,'comment' TEXT)";
    [_userDatabase executeUpdate:sql];
    
    sql = @"CREATE TABLE BeaconInfo('identify' TEXT NOT NULL PRIMARY KEY,'power' TEXT,'date' TEXT)";
    [_userDatabase executeUpdate:sql];
    
    sql = @"CREATE TABLE LocationInfo('identify' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'latitude' REAL,'longitude' REAL,'isNearMall' INTEGER,'date' TEXT,'mallName' TEXT,UNIQUE (\"identify\" ASC))";
    [_userDatabase executeUpdate:sql];
    
    sql = @"CREATE TABLE NetworkInfo('status' TEXT PRIMARY KEY,'count' INTERGER,'comment' TEXT)";
    [_userDatabase executeUpdate:sql];
    
    NSArray *netWorkStatus = @[KWifiNetworkKey,KWwanNetworkKey,KNoNetworkKey];
    NSArray *comment = @[@"使用WIFI的次数",@"使用普通网络的次数",@"不使用网络的次数"];
    
    sql = @"INSERT INTO NetworkInfo(status,count,comment) VALUES (?,?,?)";
    for (int index = 0; index < 3; index++){
        [_userDatabase executeUpdate:sql withArgumentsInArray:@[netWorkStatus[index],@0,comment[index]]];
    }
}
#pragma mark
#pragma mark Insert UserDatabase Data
- (void)saveMallInfo:(id)mall {
    NSString *identify = nil;
    id <YTMall> tmpMall = mall;
    if ([mall isMemberOfClass:[YTCloudMall class]]) {
        identify = [mall localDB];
    }else if([mall isMemberOfClass:[YTLocalMall class]]){
        identify = [mall identifier];
    }else{
        return;
    }
    FMResultSet *result = [_userDatabase executeQuery:@"SELECT identify,count FROM MallInfo WHERE identify = ?",identify];
    if (![result next]){
        [_userDatabase executeUpdate:@"INSERT INTO MallInfo('identify','name','count') VALUES(?,?,?)",identify,[tmpMall mallName],@0];
    }else{
        NSInteger count = [result intForColumn:@"count"];
        [_userDatabase executeUpdate:@"UPDATE MallInfo SET count = ? WHERE identify = ?",[NSNumber numberWithInteger:count + 1],identify];
    }
}

- (void)saveMerchantInfo:(id)merchant {
    NSString *identify = nil;
    NSString *name = nil;
    NSString *comment = nil;
    if ([merchant isKindOfClass:[YTCloudMerchant class]]) {
        identify = [(YTCloudMerchant *)merchant uniId];
        name = [(YTCloudMerchant *)merchant merchantName];
        comment = [[(YTCloudMerchant *)merchant mall] mallName];
    }else if([merchant isKindOfClass:[YTLocalMerchantInstance class]]){
        identify = [(YTLocalMerchantInstance *)merchant uniId];
        name = [(YTLocalMerchantInstance *)merchant merchantLocationName];
        comment = [[(YTLocalMerchantInstance *)merchant mall] mallName];
    }else{
        return;
    }
    
    FMResultSet *result = [_userDatabase executeQuery:@"SELECT identify,count FROM MerchantInfo WHERE identify = ?",identify];
    if ([result next]) {
        NSInteger count = [result intForColumn:@"count"];
        [_userDatabase executeUpdate:@"UPDATE MerchantInfo SET count = ? WHERE identify = ?",[NSNumber numberWithInteger:count + 1],identify];
    }else{
        [_userDatabase executeUpdate:@"INSERT INTO MerchantInfo('identify','name','count','comment') VALUES(?,?,?,?)",identify,name,@0,comment];
    }
}

- (void)saveLocationInfo:(CLLocationCoordinate2D)coord name:(NSString *)name {
    NSNumber *isNearMall = @0;
    if (name) {
        isNearMall = @1;
    }else{
        name = @"";
    }
    NSNumber *latitude = [NSNumber numberWithDouble:coord.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:coord.longitude];
    [_userDatabase executeUpdate:@"INSERT INTO LocationInfo('latitude','longitude','isNearMall','mallName','date') VALUES(?,?,?,?,?)",latitude,longitude,isNearMall,name,_date];
}

-(void)saveBeaconInfo:(ESTBeacon *)beacon {
    NSString *identify = [NSString stringWithFormat:@"%@-%@",[beacon.major stringValue],[beacon.minor stringValue]];
    FMResultSet *result = [_userDatabase executeQuery:@"SELECT identify FROM BeaconInfo WHERE identify = ?",identify];
    if ([result next]) {
        [_userDatabase executeUpdate:@"UPDATE BeaconInfo SET date = ? , power = ? WHERE identify = ?",_date,[beacon.batteryLevel stringValue],identify];
    }else{
        [_userDatabase executeUpdate:@"INSERT INTO BeaconInfo('identify','date','power') VALUES (?,?,?)",identify,_date,[beacon.batteryLevel stringValue]];
    }
}

#pragma mark
#pragma mark 跳过云备份
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)url{
    if (url != nil){
        assert([[NSFileManager defaultManager] fileExistsAtPath:[url path]]);
        NSError *error = nil;
        BOOL success = [url setResourceValue:[NSNumber numberWithBool:true] forKey:NSURLIsExcludedFromBackupKey error:&error];
        if (!success) {
            NSLog(@"错误信息:%@",error);
        }
        return success;
    }
    return false;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
