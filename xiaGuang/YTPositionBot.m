//
//  PositionBot.m
//  Positioning
//
//  Created by Meng Hu on 10/21/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import "YTPositionBot.h"
#import "YTDistanceData.h"

#import "YTMatrixToolBox.h"

#import <Accelerate/Accelerate.h>

@implementation YTPositionBot

- (NSValue *)locateMeWithDistances:(NSArray *)distances
                          accuracy:(double)accuracy {
    
    if ([distances count] < 1) {
        return nil;
    } else if ([distances count] == 1) {
        YTDistanceData *dist = distances[0];
        return [NSValue valueWithCGPoint:CGPointMake(dist.x, dist.y)];
    }
    
    NSArray *sortedDist = [distances sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        YTDistanceData *d1 = (YTDistanceData *)obj1;
        YTDistanceData *d2 = (YTDistanceData *)obj2;
        return [[NSNumber numberWithFloat:d1.distance] compare:[NSNumber numberWithFloat:d2.distance]];
    }];
    
    double x = 0;
    double y = 0;
    
    int count = MIN((int)[sortedDist count], 4);
    
    for (int i = 0; i < count; i++) {
        x += ((YTDistanceData *)sortedDist[i]).x;
        y += ((YTDistanceData *)sortedDist[i]).y;
    }
    
    x /= count;
    y /= count;
    
    int roundThreshold = 100000;
    
    for (int k = 0; k < roundThreshold; k++) {
        
        // Calculating J^T * J
        double a11,a12,a21,a22;
        a11 = a12 = a21 = a22 = 0.0;
        
        for (int i = 0; i < count; i++) {
            YTDistanceData *dist_i = sortedDist[i];
            
            double d_square = pow(x - dist_i.x, 2) + pow(y - dist_i.y, 2);
            
            if (d_square != 0) {
                a11 += pow(x - dist_i.x, 2) / d_square;
                a12 += (x - dist_i.x) * (y - dist_i.y) / d_square;
                a21 = a12;
                a22 += pow(y - dist_i.y, 2) / d_square;
            }
        }
        
        // Invert
        double *matrix_a = (double *)malloc(4 * sizeof(double));
        matrix_a[0] = a11;
        matrix_a[1] = a12;
        matrix_a[2] = a21;
        matrix_a[3] = a22;
        
        // terrible hack for now.
        for (int i = 0; i < 4; i++) {
            matrix_a[i] *= 1000;
        }
       
        long error = [YTMatrixToolBox matrixInvertWithDimension:2 matrix:matrix_a];
        if (error != 0) {
            free(matrix_a);
            return nil;
        }
        
        // terrible hack for now.
        for (int i = 0; i < 4; i++) {
            matrix_a[i] /= 1000;
        }
        
        a11 = matrix_a[0];
        a12 = matrix_a[1];
        a21 = matrix_a[2];
        a22 = matrix_a[3];
        
        free(matrix_a);
        
        // Calculating J^T * W * f
        double b11, b21;
        b11 = b21 = 0.0;
        
        for (int i = 0; i < count; i++) {
            YTDistanceData *dist_i = sortedDist[i];
            
            double d = sqrt(pow(x - dist_i.x, 2) + pow(y - dist_i.y, 2));
            double dr_square = d * dist_i.distance * dist_i.distance;
            double f = d - dist_i.distance;
            
            if (dr_square != 0) {
                b11 += (x - dist_i.x) * f / dr_square;
                b21 += (y - dist_i.y) * f / dr_square;
            }
        }
        
        // Update x, y
        double newX = x - (a11 * b11 + a12 * b21);
        double newY = y - (a21 * b11 + a22 * b21);
        
        // Diff
        double diff = sqrtf(pow(newX - x, 2) + pow(newY - y, 2));
        
        x = newX;
        y = newY;
        
        if (diff < accuracy) {
            break;
        }
    }
    
    return [NSValue valueWithCGPoint:CGPointMake(x, y)];
}


@end
