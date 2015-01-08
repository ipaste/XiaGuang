//
//  YTMerchantIndexViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMallInfoViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTMoreCategoryViewController.h"
#import "YTMajorArea.h"
#import "YTCloudMerchant.h"
#import "YTCategory.h"
#import "YTSearchView.h"
#import "YTMerchantViewCell.h"
#import "YTMerchantInfoViewController.h"
#import "YTResultsViewController.h"
#import "YTCloudMall.h"
#import "YTMapViewController2.h"
@interface YTMallInfoViewController ()<UITableViewDataSource,UITableViewDelegate,YTSearchViewDelegate>{
    YTSearchView *_searchView;
    UIImageView *_searchBackgroundView;
    UIScrollView *_scrollView;
    NSArray *_categorys;
    UITableView *_tableView;
    NSArray *_hots;
    UIActivityIndicatorView *_loading;
    UILabel *_loadingLabel;
    UIImage *_infoBackgroundImage;
    YTMallPosistionViewController *_posistionVC;
    BOOL _isShowSearchView;
}
@end

@implementation YTMallInfoViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    _scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];
    _searchView = [[YTSearchView alloc]initWithMall:[(YTCloudMall *)self.mall getLocalCopy] placeholder:@"商城/品牌" indent:NO];
    _searchView.delegate = self;
    [_searchView setBackgroundImage:[UIImage imageNamed:@"all_bg_navbar"]];
    [_searchView addInNavigationBar:self.navigationController.navigationBar show:NO];
    
    [self.view addSubview:_scrollView];
    [self setNavigation];
    [self mainView];
    
    self.navigationItem.title = [_mall mallName];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.titleView.hidden = NO;
    [AVAnalytics beginLogPageView:@"mallInfoViewController"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AVAnalytics endLogPageView:@"mallInfoViewController"];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_isShowSearchView) {
        [_searchView hideSearchViewWithAnimation:NO];
    }

}
#pragma mark Navigation
-(void)setNavigation{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self rightBarButton]];
}


-(UIView *)rightBarButton{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
    [button addTarget:self action:@selector(jumpToSearch:) forControlEvents:UIControlEventTouchUpInside];

    [button setImage:[UIImage imageNamed:@"nav_ico_search_un"] forState:UIControlStateNormal];
     [button setImage:[UIImage imageNamed:@"nav_ico_search_pr"] forState:UIControlStateHighlighted];
    return button;
}

-(void)jumpToSearch:(UIButton *)sender{
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.titleView.hidden = YES;
    _isShowSearchView = YES;
    [_searchView showSearchViewWithAnimation:YES];
}

-(void)searchCancelButtonClicked{
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.titleView.hidden = NO;
    _isShowSearchView = NO;
    [_searchView hideSearchViewWithAnimation:NO];
}
-(void)selectedUniIds:(NSArray *)uniIds{
    YTResultsViewController *resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:self.mall andResultsLocalDBIds:uniIds];
    resultsVC.isSearch = YES;
    [self.navigationController pushViewController:resultsVC animated:YES];
}


#pragma mark View 1
-(void)mainView{
    UIButton *left = [[UIButton alloc]initWithFrame:CGRectMake(0, 10, 159, 44)];
    left.backgroundColor = [UIColor whiteColor];
    [left setTitle:@"商圈位置" forState:UIControlStateNormal];
    [left setTitleColor:[UIColor colorWithString:@"404040"] forState:UIControlStateNormal];
    [left setImage:[UIImage imageNamed:@"mall_img_location"] forState:UIControlStateNormal];
    [left setImage:[UIImage imageNamed:@"mall_img_location"] forState:UIControlStateHighlighted];
    [left setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateHighlighted];
    [left addTarget:self action:@selector(showMallPosition:) forControlEvents:UIControlEventTouchUpInside];
    [left.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [left setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    
    UIButton *right = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(left.frame)+ 1, CGRectGetMinY(left.frame), CGRectGetWidth(left.frame), CGRectGetHeight(left.frame))];
    right.backgroundColor = [UIColor whiteColor];
    [right setTitle:@"楼层地图" forState:UIControlStateNormal];
    [right setTitleColor:[UIColor colorWithString:@"404040"] forState:UIControlStateNormal];
    [right setImage:[UIImage imageNamed:@"mall_img_floor"] forState:UIControlStateNormal];
    [right setImage:[UIImage imageNamed:@"mall_img_floor"] forState:UIControlStateHighlighted];
    [right setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateHighlighted];
    [right addTarget:self action:@selector(jumpToFloorMap:) forControlEvents:UIControlEventTouchUpInside];
    [right.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [right setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    
    UIView *categoryView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(right.frame) + 10, CGRectGetWidth(_scrollView.frame), 200)];
    categoryView.backgroundColor = [UIColor whiteColor];
    _categorys = [YTCategory commonlyCategorysWithAddMore:YES];
    for (int i = 0; i < _categorys.count; i++) {
        UIButton *categoryBtn = [[UIButton alloc]initWithFrame:CGRectMake(15 + i % 4 * 80, 15 + i / 4  * 93, 50, 50)];
        YTCategory *category = _categorys[i];
        [categoryBtn setImage:category.image forState:UIControlStateNormal];
        [categoryBtn addTarget:self action:@selector(jumpToCategory:) forControlEvents:UIControlEventTouchUpInside];
        categoryBtn.tag = i;
        [categoryView addSubview:categoryBtn];
        
        UILabel *categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(categoryBtn.frame) + 8, 50, 20)];
        categoryLabel.center = CGPointMake(categoryBtn.center.x, categoryLabel.center.y);
        NSString *title = category.text;
        if ([title isEqualToString:@"全部分类"]) {
            title = @"更多";
        }
        categoryLabel.text = title;
        categoryLabel.tintColor = [UIColor colorWithString:@"808080"];
        categoryLabel.textAlignment = 1;
        categoryLabel.font = [UIFont systemFontOfSize:14];
        [categoryView addSubview:categoryLabel];
    }
    
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(categoryView.frame) + 10, CGRectGetWidth(_scrollView.frame), 35) style:UITableViewStylePlain];
    _tableView.scrollEnabled = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    _loading = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = _loading.frame;
    frame.origin.x = CGRectGetWidth(_scrollView.frame) / 2 - 50;
    frame.origin.y = CGRectGetMaxY(_tableView.frame) + 20;
    _loading.frame = frame;
    [_loading startAnimating];
    _loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_loading.frame) + 5, CGRectGetMinY(_loading.frame), 84, CGRectGetHeight(_loading.frame))];
    _loadingLabel.text = @"正在加载数据";
    _loadingLabel.textColor = _loading.color;
    _loadingLabel.font = [UIFont systemFontOfSize:14];
    [_scrollView addSubview:_loadingLabel];
    [_scrollView addSubview:_loading];
    
    [_scrollView addSubview:left];
    [_scrollView addSubview:right];
    [_scrollView addSubview:categoryView];
    [_scrollView addSubview:_tableView];
 
    [self getHotsBlack:^(NSArray *merchants) {
        [_loading stopAnimating];
        [_loading removeFromSuperview];
        [_loadingLabel removeFromSuperview];
        _hots = merchants;
        CGRect frame = _tableView.frame;
        frame.size.height = (_hots.count * 90) + 35;
        _tableView.frame = frame;
        [_tableView reloadData];
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), CGRectGetMaxY(_tableView.frame) + 70);
    }];
    
    id<YTMall> mall = _mall;
    
    if (mall == nil) {
        [[[UIAlertView alloc]initWithTitle:@"对不起" message:@"您的网络状况不好，无法显示商城内容，请检查是否开启无线网络" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil]show];
    }
    [mall getMallBasicInfoWithCallBack:^(UIImage *mapImage, NSString *address, NSString *phoneNumber, NSError *error) {
        _posistionVC = [[YTMallPosistionViewController alloc]initWithImage:mapImage address:address phoneNumber:phoneNumber];
    }];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _hots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMerchantViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[YTMerchantViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.merchant = _hots[indexPath.row];
    
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *background = [[UIView alloc]init];
    background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollView.frame), 33)];
    label.backgroundColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.text = @"热门品牌";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor colorWithString:@"606060"];
    
    [background addSubview:label];
    return background;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMerchantViewCell *cell = (YTMerchantViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    YTMerchantInfoViewController *merchantInfoVC = [[YTMerchantInfoViewController alloc]initWithMerchant:cell.merchant];
    [self.navigationController pushViewController:merchantInfoVC animated:YES];
    cell.selected = NO;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

-(void)jumpToCategory:(UIButton *)sender{
    YTCategory *category = _categorys[sender.tag];
    if (sender.tag == _categorys.count - 1) {
        YTMoreCategoryViewController *moreVC = [[YTMoreCategoryViewController alloc]init];
        moreVC.mall = self.mall;
        moreVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:moreVC animated:YES];
    }else{
        YTResultsViewController *resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:self.mall andResutsKey:category.text];
        [self.navigationController pushViewController:resultsVC animated:YES];
    }
}
-(void)jumpToFloorMap:(UIButton *)sender{
    id <YTFloor> floor = nil;
    YTLocalMall *localmall = [(YTCloudMall*)self.mall getLocalCopy];
    if (localmall == nil){
        [[[UIAlertView alloc]initWithTitle:@"虾逛" message:@"地图正在建设中." delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil]show];
        return;
    }
    NSArray * temp = [[[localmall blocks] objectAtIndex:0] floors];
    floor = [temp objectAtIndex:0];
    if (floor != nil) {
        YTMapViewController2 *mapVC = [[YTMapViewController2 alloc]initWithFloor:floor];
        mapVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:mapVC animated:YES completion:nil];
    }
}

-(void)getHotsBlack:(void (^)(NSArray *merchants))black{
    AVQuery *query = [AVQuery queryWithClassName:MERCHANT_CLASS_NAME];
    [query whereKeyExists:@"uniId"];
    [query whereKey:@"uniId" notEqualTo:@"0"];
    query.cachePolicy = kAVCachePolicyCacheElseNetwork;
    query.maxCacheAge = 1 * 3600;
    AVObject *mall = [AVObject objectWithoutDataWithClassName:@"Mall" objectId:[_mall identifier]];
    [query whereKey:@"mall" equalTo:mall];
    [query includeKey:@"mall,floor"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *merchants = [NSMutableArray array];
            for (AVObject *object in objects) {
                YTCloudMerchant *merchant = [[YTCloudMerchant alloc]initWithAVObject:object];
                [merchants addObject:merchant];
            }
            black([merchants copy]);
            [merchants removeAllObjects];
        }
        else{
            [[[UIAlertView alloc]initWithTitle:@"对不起" message:@"您的网络状况不好，无法显示商城内容，请检查是否开启无线网络" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil]show];
            
        }
    }];
    
}



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showMallPosition:(UIButton *)sender{
    [AVAnalytics event:@"showMallmap"];
    if (_posistionVC){
        [self.navigationController pushViewController:_posistionVC animated:YES];
    }
}

-(void)dealloc{
    [_searchView removeFromSuperview];
    if (_posistionVC) {
        [_posistionVC removeFromParentViewController];
        _posistionVC = nil;
    }
    NSLog(@"mallInfoDealloc");}

@end
