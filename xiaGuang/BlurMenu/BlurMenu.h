//
//  BlurMenu.h
//  BlurMenu
//
//  Created by Ali Yılmaz on 06/02/14.
//  Copyright (c) 2014 Ali Yılmaz. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>
#import "UIImage+ImageEffects.h"
#import "BlurMenuItemCell.h"

@class BlurMenu;

@protocol BlurMenuDelegate <NSObject>
@optional
- (void)menuDidShow;
- (void)menuDidHide;
- (void)selectedItemAtIndex:(NSInteger)index;
@end

@interface BlurMenu : UIView <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    id<BlurMenuDelegate> delegate;
    UIView *parent;
    NSArray *menuItems;
    UICollectionView *_collectionView;
}

@property(nonatomic, retain) id <BlurMenuDelegate> delegate;
@property(nonatomic, retain) UIView *parent;
@property(nonatomic, retain) NSArray *menuItems;
@property(nonatomic, retain) UICollectionView *_collectionView;

- (id)initWithItems:(NSArray*)items parentView:(UIView *)p delegate:(id<BlurMenuDelegate>)d;

- (void)show;
- (void)hide;

@end
