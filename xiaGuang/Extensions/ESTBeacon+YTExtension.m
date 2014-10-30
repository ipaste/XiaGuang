//
//  ESTBeacon+YTExtension.m
//  Demo
//
//  Created by Yuan Tao on 8/3/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "ESTBeacon+YTExtension.h"

@implementation ESTBeacon (YTExtension)

-(BOOL) equalTo:(ESTBeacon *)beacon{
    
    if(beacon == NULL){
        return false;
    }
    
    if(self.major == beacon.major && self.minor == beacon.minor &&self.proximityUUID == beacon.proximityUUID){
        return true;
    }
    else{
        return false;
    }
}

@end
