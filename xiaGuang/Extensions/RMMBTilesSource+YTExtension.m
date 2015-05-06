//
//  RMMBTilesSource+YTExtension.m
//  虾逛
//
//  Created by Yuan Tao on 11/20/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "RMMBTilesSource+YTExtension.h"
#define CURRENT_DATA_DIR [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingString:@"/current/data/"]

@implementation RMMBTilesSource (YTExtension)

- (id)initWithTileSetResourceInDocument:(NSString *)name ofType:(NSString *)extension{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *path = [NSString stringWithFormat:@"%@/%@.%@",CURRENT_DATA_DIR,name,extension];
    if (![fileManager fileExistsAtPath:path]) {
        return nil;
    }
    return [self initWithTileSetURL:[NSURL fileURLWithPath:path]];
}

@end

