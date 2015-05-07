//
//  YTSearchView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-10-16.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSearchView.h"
#import "YTSearchDetailsView.h"
#import <AVOSCloud/AVOSCloud.h>
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "AppDelegate.h"

NSString *const kViewControllerKey = @"viewController";
NSString *const kNavigationTitleKey = @"title";
NSString *const kLeftBarItemKey = @"leftBarItem";
NSString *const kRightBarItemKey = @"rightBarItem";
@interface YTSearchView()<UISearchBarDelegate,YTSearchDetailsDelegate>{
    id<YTMall> _mall;
    UISearchBar *_searchBar;
    UITextField *_searchTextField;
    NSString *_placeholder;
    UIImageView *_searchLeftImageView;
    UIButton *_searchClearButton;
    UIButton *_cancelButton;
    BOOL _isAddInNavigationBar;
    BOOL _displayFirstResponder;
    BOOL _isIndent;
    BOOL _isHide;
    YTSearchDetailsView *_detailsView;
    CGFloat _searchBarWidth;
    CGFloat _searchTextFieldWidth;
    NSMutableDictionary *_object;
}
@end
@implementation YTSearchView
-(instancetype)initWithMall:(id<YTMall>)mall placeholder:(NSString *)placeholder indent:(BOOL)indent{
    _mall = mall;
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        CGFloat searchBarX = 5;
        _isHide = true;
        _searchBarWidth =  CGRectGetWidth(self.frame) - 40;
        CGFloat cancelX = CGRectGetWidth(self.frame) - 40;
        if (indent) {
            _isIndent = indent;
            searchBarX = -10;
            cancelX = CGRectGetWidth(self.frame) - 80;
        }
        if([[UIDevice currentDevice].systemVersion hasPrefix:@"8"]){
            _searchBarWidth = _searchBarWidth - 5;
        }
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(searchBarX,27, _searchBarWidth, 30)];
        _placeholder = placeholder;
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索";
        
        _searchTextField = [self getTextFieldFromSearchBar:_searchBar];
        _searchTextField.leftViewMode = UITextFieldViewModeAlways;
        UIImage *leftImage = [UIImage imageNamed:@"icon_search"];
        _searchLeftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, leftImage.size.width,  leftImage.size.height)];
        _searchLeftImageView.image = leftImage;
        [self addSubview:_searchBar];
        
        
        _searchClearButton = [[UIButton alloc]init];
        [_searchClearButton addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
        _searchClearButton.hidden = YES;
        [_searchBar addSubview:_searchClearButton];
        
        _cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(cancelX, 20, 30, 40)];
        _cancelButton.hidden = YES;
        [_cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
        [self setBackgroundImage:nil];
        
    }
    return self;
}

-(void)layoutSubviews{
    //searchaBar
    _searchTextField.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    _searchTextField.layer.cornerRadius = 5;
    
    _searchTextField.layer.masksToBounds = YES;
    _searchTextField.clearButtonMode = UITextFieldViewModeNever;
    _searchTextField.font = [UIFont systemFontOfSize:14];
    _searchTextField.textColor = [UIColor whiteColor];
    _searchTextField.attributedPlaceholder = [[NSAttributedString alloc]initWithString:_placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithString:@"e65e37"],NSFontAttributeName : [UIFont systemFontOfSize:13]}];
    _searchTextField.leftView = _searchLeftImageView;
    _searchTextField.tintColor = [UIColor colorWithString:@"e65e37"];
    
    
    //clearButton
    UIImage *rightImage = [UIImage imageNamed:@"search_ico_delete_un"];
  
    _searchClearButton.frame = CGRectMake(_searchTextFieldWidth - rightImage.size.width - 5, 0, rightImage.size.width, rightImage.size.height);
    
    [_searchClearButton setImage:rightImage forState:UIControlStateNormal];
    [_searchClearButton setImage:[UIImage imageNamed:@"search_ico_delete_pr"] forState:UIControlStateHighlighted];
    
    [_cancelButton setCenter:CGPointMake(_cancelButton.center.x, _searchBar.center.y)];
    [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor colorWithString:@"e65e37"] forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor colorWithString:@"ffffff"] forState:UIControlStateHighlighted];
    
    
}

-(void)addInNavigationBar:(UINavigationBar *)naviBar show:(BOOL)show{
    _isAddInNavigationBar = YES;
    CGRect frame = self.frame;
    if (_isIndent) {
        frame.origin.x = 40;
    }
    frame.origin.y -= 20;
    frame.size.height = CGRectGetHeight(naviBar.frame) + 20;
    self.frame = frame;
    [naviBar addSubview:self];
    
    frame.origin.y = CGRectGetMaxY(self.frame) + 20;
    frame.size.height = CGRectGetHeight([UIScreen mainScreen].bounds) - frame.origin.y;
    
    UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication]delegate]window];
    frame.origin.x = 0;
    [self searchDetailsViewInitWithFrame:frame addInView:window];
    if (show) {
        _displayFirstResponder = NO;
        [self showSearchViewWithAnimation:NO];
    }else{
        _displayFirstResponder = YES;
        [self hideSearchViewWithAnimation:NO];
    }
    
    if (_isAddInNavigationBar) {
        _object = [NSMutableDictionary dictionary];
        for (UIView *view = [self superview]; view; view = view.superview) {
            UIResponder *responder = [view nextResponder];
            if ([responder isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navigationController = (UINavigationController *)responder;
                UIViewController *viewController = navigationController.visibleViewController;
                NSString *title = viewController.navigationItem.title;
                UIBarButtonItem *rightBarItem = viewController.navigationItem.rightBarButtonItem;
                UIBarButtonItem *leftBarItem = viewController.navigationItem.leftBarButtonItem;
                if (title) {
                    [_object setObject:title forKey:kNavigationTitleKey];
                }
                if (rightBarItem) {
                    [_object setObject:rightBarItem forKey:kRightBarItemKey];
                }else{
                    _isHide = false;
                }
                if (leftBarItem) {
                    [_object setObject:leftBarItem forKey:kLeftBarItemKey];
                }
                [_object setObject:viewController forKey:kViewControllerKey];
                return;
            }
        }
    }
}


-(void)addInView:(UIView *)view show:(BOOL)show{
    _isAddInNavigationBar = NO;
    CGRect frame = self.frame;
    if (show) {
        _displayFirstResponder = NO;
        [self showSearchViewWithAnimation:NO];
    }else{
        _displayFirstResponder = YES;
        [self hideSearchViewWithAnimation:NO];
    }
    frame.origin.y = 0;
    frame.size.height = 64;
    self.frame = frame;
    
    [view addSubview:self];
    frame.origin.y = 64;
    frame.size.height = CGRectGetHeight(view.frame) - frame.origin.y;
    [self searchDetailsViewInitWithFrame:frame addInView:view];
}

-(void)setBackgroundImage:(UIImage *)image{
    if(image){
        self.backgroundColor = [UIColor colorWithPatternImage:image];
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)showSearchViewWithAnimation:(BOOL)animation{
    if (_object[kViewControllerKey]) {
        UIViewController *viewController = _object[kViewControllerKey];
        viewController.navigationItem.title = @"";
        viewController.navigationItem.rightBarButtonItem = nil;
        if (!animation){
            viewController.navigationItem.leftBarButtonItem = _object[kLeftBarItemKey];
        }
    }
    if (_searchBar.hidden){
        _searchBar.hidden = false;
    }
    
    if (_displayFirstResponder) {
        [_searchBar becomeFirstResponder];
    }
    
    self.hidden = false;
}

- (void)hideSearchViewWithAnimation:(BOOL)animation{
    if (!_searchBar.hidden){
        _searchBar.hidden = true;
    }
    self.hidden = true;
}

#pragma mark searchBar的协议
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchBar:searchBar dealWithTextChange:searchText];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    _detailsView.hidden = NO;
    if (_object[kLeftBarItemKey]) {
        UIViewController *viewController = _object[kViewControllerKey];
        viewController.navigationItem.leftBarButtonItem = nil;
    }
    if (_searchTextFieldWidth == 0) {
        _searchTextFieldWidth = CGRectGetWidth(_searchTextField.frame);
    }
    [UIView animateWithDuration:.2 animations:^{
        
        _searchTextFieldWidth -= 5;
        
        CGRect frame;
        frame = _searchTextField.frame;
        frame.size.width = _searchTextFieldWidth;
        _searchTextField.frame = frame;
        
        
        frame = self.frame;
        frame.origin.x = 0;
        self.frame = frame;
        
        frame = _searchBar.frame;
        frame.origin.x = 5;
        frame.size.width = _searchTextFieldWidth;
        _searchBar.frame = frame;
        
        frame = _cancelButton.frame;
        if ([[UIDevice currentDevice].systemVersion hasPrefix:@"8"]){
            frame.origin.x = CGRectGetMaxX(_searchTextField.frame) + 10;
        }else{
            frame.origin.x = CGRectGetMaxX(_searchTextField.frame) + 5;
        }
        _cancelButton.frame = frame;
        
    } completion:^(BOOL finished) {
        _cancelButton.hidden = NO;
        
    }];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (_detailsView != nil) {
        [_detailsView searchButtonClicked];
    }
}

-(void)searchBar:(UISearchBar *)searchBar dealWithTextChange:(NSString *)searchText{
    searchBar.text = searchText;
    if (searchText.length <= 0) {
        _searchClearButton.hidden = YES;
    }else if(_searchClearButton.hidden == YES){
        _searchClearButton.hidden = NO;
    }
    [_detailsView searchWithKeyword:searchText];
}

#pragma mark detailsView协议
-(void)cancelSearchInput{
    [_searchBar resignFirstResponder];
}


-(void)selectSearchResultsWithUniIds:(NSArray *)uniIds{
    [AVAnalytics event:@"选中某搜索结果"];
    
    if ([self.delegate respondsToSelector:@selector(searchCancelButtonClicked)]){
        [self.delegate searchCancelButtonClicked];
    }
    [self cancelAnimation:false completion:nil];
    [self.delegate selectedUniIds:uniIds];
}

#pragma mark clear按钮 cancel按钮
-(void)clearText{
    [self searchBar:_searchBar dealWithTextChange:@""];
}

-(void)clickCancelButton:(UIButton *)sender{
    [self cancelAnimation:true completion:nil];
}

-(void)cancelAnimation:(BOOL)animation completion:(void (^)(void))completion{
    if (_isAddInNavigationBar) {
        UIViewController *viewController = _object[kViewControllerKey];
        viewController.navigationItem.title = _object[kNavigationTitleKey];
        viewController.navigationItem.leftBarButtonItem = _object[kLeftBarItemKey];
        viewController.navigationItem.rightBarButtonItem = _object[kRightBarItemKey]; 
    }
    self.hidden = _isHide;
    _cancelButton.hidden = true;
    _detailsView.hidden = true;
    [_searchBar resignFirstResponder];
    [self searchBar:_searchBar dealWithTextChange:@""];
    NSTimeInterval duration = 0;
    if (animation) {
        duration = .2;
    }
    _searchTextFieldWidth += 5;
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = _searchTextField.frame;
        frame.size.width = _searchTextFieldWidth;
        _searchTextField.frame = frame;
        
        frame = self.frame;
        frame.origin.x = 40;
        self.frame = frame;
        
        frame = _searchBar.frame;
        frame.origin.x = -10;
        frame.size.width = CGRectGetWidth(self.frame) - 40;
        _searchBar.frame = frame;
        
        
    } completion:^(BOOL finished) {
        if (completion != nil) {
            completion();
        }
    }];
}
#pragma mark 创建searchDetailsView并设置frame
-(void)searchDetailsViewInitWithFrame:(CGRect)frame addInView:(UIView *)view{
    if (_detailsView == nil) {
        _detailsView = [[YTSearchDetailsView alloc]initWithFrame:frame andDataSourceMall:_mall];
        _detailsView.delegate = self;
        [view addSubview:_detailsView];
    }
    
}

-(UITextField *)getTextFieldFromSearchBar:(UISearchBar *)searchBar{
    UIView *contentView = [searchBar.subviews firstObject];
    [[[contentView subviews] firstObject] removeFromSuperview];
    return [[contentView subviews] firstObject];
}


- (void)removeFromSuperview{
    [super removeFromSuperview];
    [_object removeAllObjects];
}

-(void)dealloc{
    [_detailsView removeFromSuperview];
    _detailsView = nil;
    [_searchBar removeFromSuperview];
}
@end
