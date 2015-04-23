//
//  YTCategoryResultsTableView.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-22.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTLocalMall.h"
#import "YTCategory.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTSelectCategoryViewCell.h"
#import "YTDataManager.h"
typedef NS_ENUM(NSInteger, YTCategoryResultsStyle) {
    YTCategoryResultsStyleAllCategory,
    YTCategoryResultsStyleAllMall,
    YTCategoryResultsStyleAllFloor
};
@protocol YTCategoryDelegate <NSObject>

-(void)selectKey:(NSString *)key;

@end

@interface YTCategoryResultsTableView : UIView
@property (nonatomic,readonly) YTCategoryResultsStyle style;
@property (weak,nonatomic) id <YTCategoryDelegate> delegate;
-(void)setShowStyle:(YTCategoryResultsStyle)style mallName:(NSString *)mallName key:(NSString *)key;
@end
