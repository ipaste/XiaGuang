//
//  YTSearchViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-11.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSearchViewController.h"
#import "YTCategoryViewCell.h"
#import "YTCategory.h"
#import "YTSearchView.h"
#import "YTCloudMerchant.h"
#import "YTResultsViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTPageControl.h"
#define TABLEVIEW_HEAD 110.0f
@interface YTSearchViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,YTSearchViewDelegate>{
    UITableView *_tableView;
    YTPageControl *_pageControl;
    YTSearchView *_searchView;
    NSArray *_categorys;
    NSArray *_images;
    NSMutableArray *_slideImageViews;
    BOOL _isManualSwitch;
}
@end

@implementation YTSearchViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"虾逛";
    self.navigationItem.titleView = [[UIView alloc]init];
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"all_bg_navbar-1"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButtonItemCustomView]];
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    //_tableView.tableHeaderView = [self tableHeadView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    _categorys = [YTCategory allCategorys];
    
    _isManualSwitch = YES;
    _searchView = [[YTSearchView alloc]initWithMall:nil placeholder:@"搜索" indent:YES];
    _searchView.delegate = self;
    [_searchView addInNavigationBar:self.navigationController.navigationBar show:YES];
    
}
-(UIView *)leftBarButtonItemCustomView{
    UIImage *backImage = [UIImage imageNamed:@"nav_ico_back_un"];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"nav_ico_back_pr"] forState:UIControlStateHighlighted];
    [backButton setImage:backImage forState:UIControlStateNormal];
    return backButton;
}

-(UIView *)tableHeadView{
    UIView *background = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), TABLEVIEW_HEAD)];
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), TABLEVIEW_HEAD)];
    scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
    scrollView.tag = 2;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentOffset = CGPointMake(1 * CGRectGetWidth(scrollView.frame) , 0);
    
    
    _images = @[@"home3_img_pic@2x.jpg",@"home3_img_pic3@2x.jpg",@"home3_img_pic4@2x.jpg"];
    _slideImageViews = [NSMutableArray array];
    
    for (int i = 0 ; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i * CGRectGetWidth(scrollView.frame), 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame))];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",_images[i]]];
        imageView.tag = i;
        [scrollView addSubview:imageView];
        [_slideImageViews addObject:imageView];
    }
    
    _pageControl = [[YTPageControl alloc]initWithFrame:CGRectMake(0, TABLEVIEW_HEAD - 15, 320, 10)];
    _pageControl.center = CGPointMake(background.center.x, _pageControl.center.y);
    _pageControl.numberOfPages = _images.count;
    _pageControl.currentPage = 0;
    _pageControl.userInteractionEnabled = NO;
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(background.frame) - 1, CGRectGetWidth(background.frame), 1)];
    lineView.backgroundColor = [UIColor colorWithString:@"dcdcdc"];
    [background addSubview:scrollView];
    [background addSubview:_pageControl];
    [background addSubview:lineView];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(bannerSwitch:) userInfo:scrollView repeats:YES];
    return background;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_searchView showSearchViewWithAnimation:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_searchView hideSearchViewWithAnimation:NO];
}


-(void)viewWillLayoutSubviews{
    CGFloat topHeight = [self.topLayoutGuide length];
    
    CGRect frame = _tableView.frame;
    frame.origin.y = topHeight ;
    frame.size.height = CGRectGetHeight(self.view.frame) - topHeight;
    _tableView.frame = frame;
    
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _categorys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YTCategoryViewCell *cell = [[YTCategoryViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.category = _categorys[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YTCategory *category  = _categorys[indexPath.row];
    YTResultsViewController *resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:nil andResutsKey:category.text];
    resultsVC.isSearch = NO;
    resultsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:resultsVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


-(void)selectedUniIds:(NSArray *)uniIds{
    YTResultsViewController *resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:nil andResultsLocalDBIds:uniIds];
    resultsVC.isSearch = YES;
    resultsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:resultsVC animated:YES];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.tag == 2) {

        if (_isManualSwitch) {
            [self toggleBanner:scrollView];
        }
    }
}

-(void)bannerSwitch:(NSTimer *)timer{
    _isManualSwitch = NO;
    UIScrollView *scrollView = timer.userInfo;
    [UIView animateWithDuration:.5 animations:^{
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x + CGRectGetWidth(scrollView.frame), scrollView.contentOffset.y);
    } completion:^(BOOL finished) {
        [self toggleBanner:scrollView];
        _isManualSwitch = YES;
    }];
}
-(void)toggleBanner:(UIScrollView *)scrollView{
    BOOL isSwitch = false;
    if (scrollView.contentOffset.x / scrollView.frame.size.width == 0 ) {
        //上一张
        _pageControl.currentPage = --_pageControl.currentPage;
        scrollView.contentOffset = CGPointMake(CGRectGetWidth(scrollView.frame), 0);
        isSwitch = true;
    }else if (scrollView.contentOffset.x / scrollView.frame.size.width == 2){
        //下一张
        _pageControl.currentPage = ++_pageControl.currentPage;
        
        scrollView.contentOffset = CGPointMake(CGRectGetWidth(scrollView.frame), 0);
        isSwitch = true;
    }
    
    if (isSwitch) {
        for (int i = 0; i < _images.count; i++) {
            UIImageView *curImageView = _slideImageViews[i];
            int num =  i % 3 + (int) _pageControl.currentPage;
            num = num % 3;
            curImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",_images[num]]];
        }
    }
}
-(void)back{
    [_searchView hideSearchViewWithAnimation:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(void)dealloc{
    [_searchView removeFromSuperview];
}

@end
