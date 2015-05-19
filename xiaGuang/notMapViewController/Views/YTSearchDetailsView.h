//
//  YTSearchDetailsView.h
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-15.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTMall.h"
#import "YTMerchant.h"
@class YTSearchDetailsView;
@protocol YTSearchDetailsDelegate <NSObject>
@required
-(void)selectSearchResultsWithUniIds:(NSArray *)uniIds;
-(void)selectedSeachKey:(NSString *)key;
-(void)cancelSearchInput;
@end

@interface YTSearchDetailsView : UIView

@property (weak,nonatomic)id<YTSearchDetailsDelegate> delegate;
/*
 *  mall为nil时,则搜索所有mall的店铺
 */
-(id)initWithFrame:(CGRect)frame andDataSourceMall:(id<YTMall>)mall;
-(void)searchWithKeyword:(NSString *)keyWord;
-(void)searchButtonClicked;
@end
