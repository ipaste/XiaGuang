//
//  YTMapGraphDict.m
//  虾逛
//
//  Created by Yuan Tao on 3/6/15.
//  Copyright (c) 2015 YunTop. All rights reserved.
//

#import "YTMapGraphDict.h"

@implementation YTMapGraphDict
{
    NSMutableDictionary *_idToGraph;
}

-(id)init{
    self = [super init];
    if(self){
        _idToGraph = [NSMutableDictionary new];
    }
    return self;
}


+(id)sharedInstance{
    static YTMapGraphDict *sharedInstance = nil;
    if (!sharedInstance)
    {
        
        sharedInstance = [[YTMapGraphDict alloc] init];
    }
    return sharedInstance;
}


-(YTMapGraph *)getGraphFromMajorArea:(id<YTMajorArea> )majorArea usingMapview:(RMMapView *)mapView{
    
    YTMapGraph *graph = [_idToGraph objectForKey:majorArea.identifier];
    
    if(graph == nil){
        
        graph = [[YTMapGraph alloc] initWithMajorArea:majorArea mapView:mapView];
        [_idToGraph setObject:graph forKey:[majorArea identifier]];
    }
    
    return graph;
    
}



@end

