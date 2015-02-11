//
//  YTStaticResourceDownloader.h
//  虾逛
//
//  Created by Yuan Tao on 11/27/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>
#import <FCFileManager.h>
@interface YTStaticResourceDownloader : NSObject
+(id)sharedDownloader;
-(void)startDownloadingDBVersion:(int)version;
-(void)startDownloadingMapsInUpdateTable;
-(void)startDownloadingMapsInFailTable;
@end
