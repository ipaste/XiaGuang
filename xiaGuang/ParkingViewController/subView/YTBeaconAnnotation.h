//
//  YTBeaconAnnotation.h
//  xiaGuang
//
//  Created by YunTop on 14/11/6.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTAnnotation.h"
#import "RMMarker+RMMarker_YTExtension.h"
#import "YTMinorArea.h"
@interface YTBeaconAnnotation : YTAnnotation
@property (weak,nonatomic) id<YTMinorArea> minorArea;
@end
