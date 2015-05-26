//
//  RMMBTilesSource+YTExtension.m
//  虾逛
//
//  Created by Yuan Tao on 11/20/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "RMMBTilesSource+YTExtension.h"

@implementation RMMBTilesSource (YTExtension)

- (id)initWithTileSetResourceInDocument:(NSString *)name ofType:(NSString *)extension{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *file = [NSString stringWithFormat:@"%@.%@",name,extension];
    NSString *path = [[[YTDataManager defaultDataManager] documentMapPath] stringByAppendingPathComponent:file];
    if (![fileManager fileExistsAtPath:path]) {
        return nil;
    }
    return [self initWithTileSetURL:[NSURL fileURLWithPath:path]];
}

@end
