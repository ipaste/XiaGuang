//
//  YTMapGraph.m
//  虾逛
//
//  Created by Meng Hu on 12/4/14.
//  Copyright (c) 2014 YunTop. All rights reserved.
//

#import "YTMapGraph.h"

#import "YTCanonicalCoordinate.h"

#import <PESGraphRoute.h>
#import <PESGraphRouteStep.h>

@interface YTMapGraph() {
    RMMapView *_mapView;
}

- (BOOL)loadPESGraph:(NSString *)fileName;

- (CGPoint)projectPoint:(CGPoint)point
                 toNode:(PESGraphNode *)node1
                andNode:(PESGraphNode *)node2;

@end

@implementation YTMapGraph

- (id)initWithMajorArea:(id<YTMajorArea>)majorArea
                mapView:(RMMapView *)mapView {
    self = [super init];
    if (self) {
        _graph = [[PESGraph alloc] init];
        _mapView = mapView;
        if([self loadPESGraph:majorArea.mapName]){
            return self;
        }
        else{
            return nil;
        }
    }
    return self;   
}

- (BOOL)loadPESGraph:(NSString *)fileName {
    NSString *file = [[NSBundle mainBundle] pathForResource:fileName ofType:@"csv"];
    if (file == nil) {
        return NO;
    }
    
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        
        if ([line isEqualToString:@""]) {
            continue;
        }
        
        NSArray *components = [line componentsSeparatedByString:@","];
        
        double n1_x = [components[1] doubleValue];
        double n1_y = [components[2] doubleValue];
        
        CGPoint adjustedCoord1 = [YTCanonicalCoordinate mapToCanonicalCoordinate:CLLocationCoordinate2DMake(n1_y, n1_x)
                                                                         mapView:_mapView];
        
        PESGraphNode *node1 = [self makeNodeWithPoint:adjustedCoord1];
        
        double n2_x = [components[3] doubleValue];
        double n2_y = [components[4] doubleValue];
        
        CGPoint adjustedCoord2 = [YTCanonicalCoordinate mapToCanonicalCoordinate:CLLocationCoordinate2DMake(n2_y, n2_x)
                                                                         mapView:_mapView];
        
        PESGraphNode *node2 = [self makeNodeWithPoint:adjustedCoord2];
        
        NSString *edgeId = components[0];
        
        double weight = sqrt(pow(adjustedCoord2.x - adjustedCoord1.x, 2) +
                             pow(adjustedCoord2.y - adjustedCoord1.y, 2));
        
        PESGraphEdge *edge = [PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%@^%@", node1.identifier, node2.identifier]
                                              andWeight:[NSNumber numberWithDouble:weight]];
        
        [_graph addBiDirectionalEdge:edge fromNode:node1 toNode:node2];
    }
    
    return YES;
}


- (CGPoint)projectPoint:(CGPoint)point
                 toNode:(PESGraphNode *)node1
                andNode:(PESGraphNode *)node2 {
    
    double x = 0;
    double y = 0;
    
    double x1 = [node1.additionalData[@"x"] doubleValue];
    double y1 = [node1.additionalData[@"y"] doubleValue];
    
    double x2 = [node2.additionalData[@"x"] doubleValue];
    double y2 = [node2.additionalData[@"y"] doubleValue];
    
    double x0 = point.x;
    double y0 = point.y;
    
    if (abs(x1 - x2) <= 0.1) {
        // vertical
        x = x1;
        y = y0;
    } else if (abs(y1 - y2) <= 0.1) {
        // horizontal
        x = x0;
        y = y1;
    } else {
        
        double a = (y2 - y1) / (x2 - x1);
        double b = -1;
        double c = y1 - a * x1;
        
        x = (b * (b*x0 - a*y0) - a*c) / (a*a + b*b);
        y = (a * (a*y0 - b*x0) - b*c) / (a*a + b*b);
    }
    
    
   
    if (x < MIN(x1, x2)) {
        if (x1 < x2) {
            return CGPointMake(x1, y1);
        } else {
            return CGPointMake(x2, y2);
        }
    } else if (x > MAX(x1,x2)) {
        if (x1 > x2) {
            return CGPointMake(x1, y1);
        } else {
            return CGPointMake(x2, y2);
        }
    } else if (abs(x1 - x2) < 0.1) {
        if (y < MIN(y1, y2)) {
            if (y1 < y2) {
                return CGPointMake(x1, y1);
            } else {
                return CGPointMake(x2, y2);
            }
        } else if (y > MAX(y1, y2)) {
            if (y1 > y2) {
                return CGPointMake(x1, y1);
            } else {
                return CGPointMake(x2, y2);
            }
        } else {
            return CGPointMake(x, y);
        }
    } else {
        return CGPointMake(x, y);
    }
}

- (NSDictionary *)projectToGraphFromPoint:(CGPoint)point {
    return [self projectToGraphFromPoint:point betweenNodes:nil];
}

- (NSDictionary *)projectToGraphFromPoint:(CGPoint)point
                             betweenNodes:(NSArray *)nodes {
    
    __block double minDist = INFINITY;
    __block NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [self iterateEdgesWithNodeRestrictions:nodes callback:^(PESGraphNode *node1, PESGraphNode *node2, PESGraphEdge *edge) {
        CGPoint projectedP = [self projectPoint:point toNode:node1 andNode:node2];
        double dist = sqrt(pow(projectedP.x - point.x, 2) + pow(projectedP.y - point.y, 2));
        
        if (dist < minDist) {
            minDist = dist;
            
            result[kYTMapGraphProjectionPointKey] = [NSValue valueWithCGPoint:projectedP];
            result[kYTMapGraphProjectionNode1Key] = node1;
            result[kYTMapGraphProjectionNode2Key] = node2;
            result[kYTMapGraphProjectionEdgeKey] = edge;
        }
    }];
    
    return result;  
}


- (void)iterateThroughEdges:(YTMapEdgeIterationCallback)callback {
    [self iterateEdgesWithNodeRestrictions:nil callback:callback];
}

- (void)iterateEdgesWithNodeRestrictions:(NSArray *)nodes
                                callback:(YTMapEdgeIterationCallback)callback {
    
    if (callback == nil) {
        return;
    }
    
    if (nodes == nil) {
        nodes = [[_graph nodes] allValues];
    }
    
    NSMutableSet *visitedNodes = [[NSMutableSet alloc] init];
    
    for (PESGraphNode *node in nodes) {
        NSSet *neighbors = [_graph neighborsOfNode:node];
        
        for (PESGraphNode *neighbor in neighbors) {
            if (![visitedNodes containsObject:neighbor]) {
                PESGraphEdge *edge = [_graph edgeFromNode:node toNeighboringNode:neighbor];
                callback(node, neighbor, edge);
            }
        }
        [visitedNodes addObject:node];
    }
}

- (NSArray *)shortestPathWithProjectionFrom:(CGPoint)src
                                         to:(CGPoint)dest {
    
    if (_graph == nil) {
        return;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSDictionary *projectedSrc = [self projectToGraphFromPoint:src];
    NSDictionary *projectedDest = [self projectToGraphFromPoint:dest];
   
 
    PESGraphNode *srcNode = [self makeNodeWithPoint:src];
    PESGraphNode *destNode = [self makeNodeWithPoint:dest];
    
    PESGraphNode *projectedSrcNode = [self makeNodeWithPoint:[projectedSrc[kYTMapGraphProjectionPointKey] CGPointValue]];
    PESGraphNode *projectedDestNode = [self makeNodeWithPoint:[projectedDest[kYTMapGraphProjectionPointKey] CGPointValue]];
    
    [self tweakGraphWithNode:srcNode
                   projected:projectedSrcNode
                       start:projectedSrc[kYTMapGraphProjectionNode1Key]
                         end:projectedSrc[kYTMapGraphProjectionNode2Key]];
    
    [self tweakGraphWithNode:destNode
                   projected:projectedDestNode
                       start:projectedDest[kYTMapGraphProjectionNode1Key]
                         end:projectedDest[kYTMapGraphProjectionNode2Key]];
    
    PESGraphRoute *route = [_graph shortestRouteFromNode:srcNode toNode:destNode];
    
    for (PESGraphRouteStep *step in route.steps) {
        PESGraphNode *node = step.node;
        [result addObject:[NSValue valueWithCGPoint:[node.additionalData[@"point"] CGPointValue]]];
    }
    
    [result addObject:[NSValue valueWithCGPoint:[route.endingNode.additionalData[@"point"] CGPointValue]]];
    
    [self clearTweakWithNode:srcNode
                   projected:projectedSrcNode
                       start:projectedSrc[kYTMapGraphProjectionNode1Key]
                         end:projectedSrc[kYTMapGraphProjectionNode2Key]];
    
    [self clearTweakWithNode:destNode
                   projected:projectedDestNode
                       start:projectedDest[kYTMapGraphProjectionNode1Key]
                         end:projectedDest[kYTMapGraphProjectionNode2Key]];
    
    return result;
}

- (void)tweakGraphWithNode:(PESGraphNode *)node
                 projected:(PESGraphNode *)projectedNode
                     start:(PESGraphNode *)startNode
                       end:(PESGraphNode *)endNode {
    
    PESGraphEdge *edge1 = [self makeEdgeFromNode:node toNode:projectedNode];
    [_graph addBiDirectionalEdge:edge1 fromNode:projectedNode toNode:node];
    
    if (![projectedNode.identifier isEqualToString:startNode.identifier]) {
        PESGraphEdge *edge2 = [self makeEdgeFromNode:projectedNode toNode:startNode];
        [_graph addBiDirectionalEdge:edge2 fromNode:projectedNode toNode:startNode];
    }
    
    if (![projectedNode.identifier isEqualToString:endNode.identifier]) {
        PESGraphEdge *edge3 = [self makeEdgeFromNode:projectedNode toNode:endNode];
        [_graph addBiDirectionalEdge:edge3 fromNode:projectedNode toNode:endNode];
    }
}

- (void)clearTweakWithNode:(PESGraphNode *)node
                 projected:(PESGraphNode *)projectedNode
                     start:(PESGraphNode *)startNode
                       end:(PESGraphNode *)endNode {
    
    [_graph removeBiDirectionalEdgeFromNode:node toNode:projectedNode];
    
    if (![projectedNode.identifier isEqualToString:startNode.identifier]) {
        [_graph removeBiDirectionalEdgeFromNode:projectedNode toNode:startNode];
    }
    
    if (![projectedNode.identifier isEqualToString:endNode.identifier]) {
        [_graph removeBiDirectionalEdgeFromNode:projectedNode toNode:endNode];
    }
}


- (PESGraphNode *)makeNodeWithPoint:(CGPoint)point {
    PESGraphNode *node = [PESGraphNode nodeWithIdentifier:[NSString stringWithFormat:@"%f-%f",point.x, point.y]];
    node.additionalData = [[NSMutableDictionary alloc] init];
    node.additionalData[@"x"] = [NSNumber numberWithDouble:point.x];
    node.additionalData[@"y"] = [NSNumber numberWithDouble:point.y];
    node.additionalData[@"point"] = [NSValue valueWithCGPoint:CGPointMake(point.x, point.y)];
    return node;
}

- (PESGraphEdge *)makeEdgeFromNode:(PESGraphNode *)node1
                            toNode:(PESGraphNode *)node2 {
    
    double dist = sqrt(pow([node1.additionalData[@"x"] doubleValue] - [node2.additionalData[@"x"] doubleValue], 2)
                       + pow([node1.additionalData[@"y"] doubleValue] - [node2.additionalData[@"y"] doubleValue], 2));
    
    PESGraphEdge *edge = [PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%@^%@", node1.identifier, node2.identifier]
                                          andWeight:[NSNumber numberWithDouble:dist]];
    
    return edge;
}

@end
