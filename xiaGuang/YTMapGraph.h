//
//  YTMapGraph.h
//  虾逛
//
//  Created by Meng Hu on 12/4/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YTMajorArea.h"

#import <RMMapView.h>

#import <PESGraph/PESGraph.h>
#import <PESGraph/PESGraphEdge.h>
#import <PESGraph/PESGraphNode.h>

#import "YTDataManager.h"

#define kYTMapGraphProjectionPointKey  @"projectedPoint"
#define kYTMapGraphProjectionNode1Key   @"node1"
#define kYTMapGraphProjectionNode2Key   @"node2"
#define kYTMapGraphProjectionEdgeKey    @"edge"

typedef void (^YTMapEdgeIterationCallback) (PESGraphNode* node1, PESGraphNode* node2, PESGraphEdge* edge);

@interface YTMapGraph : NSObject

@property (nonatomic, readonly) PESGraph *graph;
@property (nonatomic, readonly) id<YTMajorArea> majorArea;

- (id)initWithMajorArea:(id<YTMajorArea>)majorArea
                mapView:(RMMapView *)mapView;

- (NSDictionary *)projectToGraphFromPoint:(CGPoint)point;

- (NSDictionary *)projectToGraphFromPoint:(CGPoint)point
                             betweenNodes:(NSArray *)nodes;

- (void)iterateThroughEdges:(YTMapEdgeIterationCallback)callback;

- (NSArray *)shortestPathWithProjectionFrom:(CGPoint)src
                                         to:(CGPoint)dest;

@end
