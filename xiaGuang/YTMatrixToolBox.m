//
//  YTMatrixToolBox.m
//  Bee
//
//  Created by Meng Hu on 10/30/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import "YTMatrixToolBox.h"

@implementation YTMatrixToolBox

+ (long)matrixInvertWithDimension:(__CLPK_integer) N
                           matrix:(double *)matrix {
    __CLPK_integer num = N;
    __CLPK_integer error=0;
    __CLPK_integer *pivot = malloc(N*N*sizeof(long));
    
    double *workspace = malloc(N*sizeof(double));
    
    /*  LU factorisation */
    dgetrf_(&N, &N, matrix, &N, pivot, &error);
    
    if (error != 0) {
        free(pivot);
        free(workspace);
        return error;
    }
    
    /*  matrix inversion */
    dgetri_(&N, matrix, &N, pivot, workspace, &N, &error);
    
    if (error != 0) {
        free(pivot);
        free(workspace);
        return error;
    }
    
    for (int i = 0; i < num * num; i++) {
        if (matrix[i] == INFINITY || matrix[i] == NAN) {
            error = -30;
        }
    }
    
    free(pivot);
    free(workspace);
    return error;
}

@end
