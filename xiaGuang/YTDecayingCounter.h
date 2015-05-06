//
//  YTDecayingCounter.h
//  Bee
//
//  Created by Meng Hu on 10/28/14.
//  Copyright (c) 2014 YunTOP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTDecayingCounter : NSObject

- (id)initWithHalflife:(double) halfLife;

- (id)initWithHalflife:(double)halfLife
            initialVal:(double)value;

- (double)getVal;
- (double)increment;
- (void)setVal:(double)value;


@end
