//
//  RMMBTilesSource+YTExtension.m
//  虾逛
//
//  Created by Yuan Tao on 11/20/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "RMMBTilesSource+YTExtension.h"
#import <FCFileManager.h>
#define CURRENT_DATA_DIR [FCFileManager pathForDocumentsDirectoryWithPath:@"/current/data/"]

@implementation RMMBTilesSource (YTExtension)

- (id)initWithTileSetResourceInDocument:(NSString *)name ofType:(NSString *)extension{
    if(![FCFileManager existsItemAtPath:[NSString stringWithFormat:@"%@/%@.%@",CURRENT_DATA_DIR,name,extension]]){
        NSLog(@"%@",[NSString stringWithFormat:@"%@/%@.%@",CURRENT_DATA_DIR,name,extension]);
        return nil;
    }
    return [self initWithTileSetURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.%@",CURRENT_DATA_DIR,name,extension]]];
}

@end

