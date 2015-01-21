//
//  YTTransportGrid.m
//  虾逛
//
//  Created by Yuan Tao on 1/21/15.
//  Copyright (c) 2015 YunTop. All rights reserved.
//

#import "YTTransportGrid.h"

@implementation YTTransportGrid{
    id<YTBlock> _block;
    NSMutableArray *_escalatorDictionary;
}

-(id)initWithBlock:(id<YTBlock>)block{
    self = [super init];
    if(self){
        _block = block;
    }
    return self;
}



-(NSArray *)availableTransportFromMajorArea1:(id<YTMajorArea>)m1
                                toMajorArea2:(id<YTMajorArea>)m2{
    
    
    
    
    return nil;
    
}


-(void)constructMallGraph{
    for(id<YTFloor> tmpFloor in _block.floors){
        
        for(id<YTMajorArea> tmpMajorArea in tmpFloor.majorAreas){
            
            
            
            
            for(id<YTEscalator> tmpEscalator in tmpMajorArea.escalators){
                
            }
            
            for(id<YTEscalator> tmpElevator in tmpMajorArea.elevators){
                
            }
            
            
            
        }
    }
}

@end
