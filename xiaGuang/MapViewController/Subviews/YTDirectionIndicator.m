//
//  YTDirectionIndicator.m
//  HighGuang
//
//  Created by Yuan Tao on 8/18/14.
//  Copyright (c) 2014 Yuan Tao. All rights reserved.
//

#import "YTDirectionIndicator.h"

@implementation YTDirectionIndicator

- (id)initWithScaleInPx:(int)scale andOrigin:(CGPoint)origin
{
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, scale, scale)];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor yellowColor];
        UIImage * targetimage = [UIImage imageNamed:@"TrackingHeadingMask"];
        UIImageView *image = [[UIImageView alloc] initWithImage:targetimage];
        image.frame = CGRectMake(0, 0, scale, scale);
        image.tintColor = [UIColor whiteColor];
        [self addSubview:image];
        self.alpha = 0.5;
    }
    return self;
}

@end
