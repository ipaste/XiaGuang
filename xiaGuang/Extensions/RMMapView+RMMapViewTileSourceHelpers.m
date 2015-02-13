//
//  RMMapView+RMMapViewTileSourceHelpers.m
//  HighGuang
//
//  Created by Yuan Tao on 8/25/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "RMMapView+RMMapViewTileSourceHelpers.h"
#import "RMMBTilesSource+YTExtension.h"
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
            
            self.maxZoom = tileSource.maxZoom;
            
            break;
        }
    }
    
    
    if(!found){
        RMMBTilesSource *source;
        if(sourceName == nil){
            source = [[RMMBTilesSource alloc]initWithTileSetResource:sourceName];
        }
        else{
            source = [[RMMBTilesSource alloc] initWithTileSetResourceInDocument:sourceName ofType:@"mbtiles"];
        }
        
        if(source == nil){
            return;
        }
        source.cacheable = NO;
        
        [self addTileSource:source];
        
        [self showTileSourceAtIndex:self.tileSources.count-1];
        
        self.maxZoom = source.maxZoom;
        
    }
    
    
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
    [self reloadTileSourceAtIndex:index];
    
}

@end
