//
//  BlurMenu.m
//  BlurMenu
//
//  Created by Ali Yılmaz on 06/02/14.
//  Copyright (c) 2014 Ali Yılmaz. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "BlurMenu.h"

#define COLLECTION_VIEW_PADDING 64

#define ITEM_HEIGHT 50
#define ITEM_LINE_SPACING 10

@implementation BlurMenu{
    UIImageView *_backImageView;
}
@synthesize parent, delegate, menuItems, _collectionView;

- (id)initWithItems:(NSArray*)items parentView:(UIView *)p delegate:(id<BlurMenuDelegate>)d {
    self = [super init];
    if (self) {
        self.parent = p;
        self.delegate = d;
        self.menuItems = items;

        self.alpha = 0.0f;
        self.frame = p.frame;
        
        UIImage *background = [self blurredSnapshot];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:background];
        [self addSubview:backgroundView];
        
        CGFloat height = [self calculateCollectionViewHeight];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setMinimumLineSpacing:ITEM_LINE_SPACING];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - height) / 2, self.frame.size.width, height) collectionViewLayout:layout];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        [_collectionView registerClass:[BlurMenuItemCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_collectionView];
        
        
        UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
        close.frame = CGRectMake(0, self.frame.size.height - COLLECTION_VIEW_PADDING, self.frame.size.width, COLLECTION_VIEW_PADDING);
        close.backgroundColor = [UIColor clearColor];
        [close setTitle:@"您没打开蓝牙或者不在商圈范围内" forState:UIControlStateNormal];
        [close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        close.titleLabel.font = [UIFont fontWithName:@"GillSans-Light" size:18.0f];
        [self addSubview:close];
        
        
        UIImage *defaultBackImage = [UIImage imageNamed:@"nav_ico_back_un"];
        
        _backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 30, defaultBackImage.size.width, defaultBackImage.size.height)];
        _backImageView.image = defaultBackImage;
        _backImageView.backgroundColor = [UIColor clearColor];
        UIButton *label = [[UIButton alloc] initWithFrame:CGRectMake(15+defaultBackImage.size.width, 30, 50, defaultBackImage.size.height)];
        [label setTitle:@"主页" forState:UIControlStateNormal];
        [label setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [label addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:label];
        
        [self addSubview:_backImageView];
        
        
    }
    return self;
}

-(void)backClicked{
    [self.delegate backClicked];
}

- (void)show {
    [self.parent addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(menuDidShow)]) {
            [self.delegate menuDidShow];
        }
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(menuDidHide)]) {
            [self.delegate menuDidHide];
        }
    }];
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.menuItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BlurMenuItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.title.text = [menuItems objectAtIndex:indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(300, ITEM_HEIGHT);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(selectedItemAtIndex:)]) {
        [self.delegate selectedItemAtIndex:indexPath.row];
    }
}

#pragma mark - Calculations
- (CGFloat)currentScreenHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return screenRect.size.height;
}

- (CGFloat)maxPossibleHeight {
    CGFloat current = [self currentScreenHeight];
    return current - (COLLECTION_VIEW_PADDING*2);
}

- (CGFloat)calculateCollectionViewHeight {
    NSInteger totalItem = [self.menuItems count];
    CGFloat totalHeight = (totalItem * ITEM_HEIGHT) + (totalItem * ITEM_LINE_SPACING);
    CGFloat maxPossible = [self maxPossibleHeight];
    if (totalHeight > maxPossible) {
        return maxPossible;
    }
    return totalHeight;
}

#pragma mark - Snapshot
- (UIImage *)blurredSnapshot {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(self.parent.frame), CGRectGetHeight(self.parent.frame)), NO, 1.0f);
    [self.parent drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(self.parent.frame), CGRectGetHeight(self.parent.frame)) afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Now apply the blur effect using Apple's UIImageEffect category
    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    // Or apply any other effects available in "UIImage+ImageEffects.h"
    // UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    // UIImage *blurredSnapshotImage = [snapshotImage applyExtraLightEffect];
    
    UIGraphicsEndImageContext();
    
    return blurredSnapshotImage;
}

@end
