//
//  YTMapManager.h
//  虾逛
//
//  Created by Yuan Tao on 11/17/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FCFileManager.h>
#import <AVOSCloud/AVOSCloud.h>

@interface YTMapManager : NSObject

+(YTMapManager *)sharedManager;

-(NSArray *)checkMapVersions;

-(void)downloadMapsAndUpdateVersion:(NSArray *)mapNames;

@end
