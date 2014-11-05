//
//  YTMatrixToolBox.h
//  Bee
//
//  Created by Meng Hu on 10/30/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Accelerate/Accelerate.h>

@interface YTMatrixToolBox : NSObject

+ (long)matrixInvertWithDimension:(__CLPK_integer) N
                           matrix:(double *)matrix;

@end
