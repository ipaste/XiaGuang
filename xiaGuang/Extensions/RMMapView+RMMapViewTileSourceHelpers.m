//
//  RMMapView+RMMapViewTileSourceHelpers.m
//  HighGuang
//
//  Created by Yuan Tao on 8/25/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "RMMapView+RMMapViewTileSourceHelpers.h"

@implementation RMMapView (RMMapViewTileSourceHelpers)


-(void)addAndDisplayTileSourceNamed:(NSString *)sourceName{
    
    //[self removeAllCachedImages];
    
    NSString *sourceCacheKey = [NSString stringWithFormat:@"MBTiles%@.mbtiles",sourceName];
    
    BOOL found = false;
    NSArray * tileSources = self.tileSources;
    for(int i = 0; i<[tileSources count]; i++){
        
        RMMBTilesSource *tileSource = [tileSources objectAtIndex:i];
        if([tileSource.uniqueTilecacheKey isEqualToString:sourceCacheKey]){
            
            found = YES;
            //[self moveTileSourceAtIndex:i toIndex:[tileSources count]-1];
            [self showTileSourceAtIndex:i];
            break;
        }
    }
    
    
    if(!found){
        
        RMMBTilesSource *source = [[RMMBTilesSource alloc]initWithTileSetResource:sourceName];
        source.cacheable = NO;
        [self addTileSource:source];
        
        [self showTileSourceAtIndex:self.tileSources.count-1];
        
    }
    /*
    
    for(int j = 0; j<self.tileSources.count-1; j++){
        [[self.tileSources objectAtIndex:j] setOpaque:YES];
    }
    
    RMMBTilesSource *curTileSource = [self.tileSources objectAtIndex:self.tileSources.count-1];
    
    [curTileSource setOpaque:NO];*/
                                      
    NSString *first = [(RMMBTilesSource *)[self.tileSources objectAtIndex:self.tileSources.count-1] shortName];
    NSLog(@"special: mapname is %@",first);
    
    
}

-(void)showTileSourceAtIndex:(int)index{
    
    for(int j = 0; j<self.tileSources.count; j++){
        
        if(j == index){
            [self setAlpha:1 forTileSourceAtIndex:j];
        }
        else{
            [self setAlpha:0 forTileSourceAtIndex:j];
        }
        
    }
    
}

@end
