//
//  YTMapManager.m
//  虾逛
//
//  Created by Yuan Tao on 11/17/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTMapManager.h"

@implementation YTMapManager

+(id)sharedManager{
    static YTMapManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YTMapManager alloc] init];
    });
    return manager;
}

-(void)checkMapVersionsWithCallback:(void (^)(NSArray *result,NSError *err))callback{
    
    AVQuery *query = [AVQuery queryWithClassName:@"Map"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        
        
    }];
    
}



@end
