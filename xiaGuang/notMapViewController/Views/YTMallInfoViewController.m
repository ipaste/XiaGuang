//
//  YTMerchantIndexViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTMallInfoViewController.h"

#define ROW_HEIGHT 90
#define HEAD_HEIGHT 35
#define DEFAULT_ANIMTAION_TIME 0.5

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

NSString *const kMerchantCellIdentify = @"MerchantCell";
static NSUInteger currentImgNum = 0;

@interface YTMallInfoViewController ()<YTscrollViewDelegate>{
    UIImageView *_searchBackgroundView;
    UIImageView *_activityImgView;
    UIScrollView *_scrollView;
    YTadScrollAndPageView *_adView;
    UITableView *_tableView;
    UIButton *_leftBarButton;
    UIButton *_rightBarButton;
    UIButton *_leftButton;
    UIButton *_rightButton;
    UIButton *_scrollButton;
    UIView *_saleView;
    UIView *_categoryView;
    UIView *_lineView;
    UIView *_loadingView;
    YTSearchView *_searchView;
    YTStateView *_stateView;
    NSMutableArray *_adArr;
    NSArray *_sales;
    NSArray *_categorys;
    NSArray *_hots;
    NSTimeInterval _loadingTime;
    BOOL flag;
    id <YTMall> _mall;
    YTMallDict *_mallDict;
    YTDataManager *_dataManager;
    
    YTMallPositionViewController *_poisitionViewController;
}

@end

@implementation YTMallInfoViewController

- (instancetype)initWithMallIdentify:(NSString *)identify{
    self = [super init];
    if (self) {
        _mallDict = [YTMallDict sharedInstance];
        _mall = [_mallDict getMallFromIdentifier:identify];
        if ([_mall isMemberOfClass:[YTLocalMall class]]) {
            _mall = [_mallDict changeMallObject:_mall resultType:YTMallClassCloud];
        }
        _searchView = [[YTSearchView alloc]initWithMall:_mall placeholder:@"商城/品牌" indent:false];
        _searchView.delegate  = self;
        _dataManager = [YTDataManager defaultDataManager];
        if ([_dataManager currentNetworkStatus] == YTNetworkSatusNotNomal) {
            _stateView = [[YTStateView alloc]initWithStateType:YTStateTypeNoNetWork];
        }else{
            _stateView = [[YTStateView alloc]initWithStateType:YTStateTypeLoading];
            [_stateView startAnimation];
        }
        [_mall getMallBasicMallInfoWithCallBack:^(NSString *mallName, NSString *address, CLLocationCoordinate2D coord, NSError *error) {
            _poisitionViewController = [[YTMallPositionViewController alloc]initWithMallCoordinate:[_mall coord] address:address mallName:[_mall mallName]];
        }];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self defaultNavigationBar];
    _loadingTime = [[NSDate date]timeIntervalSinceReferenceDate];
    
    [_searchView addInNavigationBar:self.navigationController.navigationBar show:false];
    _scrollView = [[UIScrollView alloc]init];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsVerticalScrollIndicator = false;
    _scrollView.scrollEnabled = false;
    [self.view addSubview:_scrollView];

    _leftButton = [[UIButton alloc]init];
    _leftButton.backgroundColor = [UIColor colorWithString:@"ebebeb" alpha:0.2];
    [_leftButton setTitle:@"商圈位置" forState:UIControlStateNormal];
    [_leftButton setTitleColor:[UIColor colorWithString:@"e5e5e5"] forState:UIControlStateNormal];
    [_leftButton setImage:[UIImage imageNamed:@"mall_img_location"] forState:UIControlStateNormal];
    [_leftButton setImage:[UIImage imageNamed:@"mall_img_location"] forState:UIControlStateHighlighted];
    [_leftButton setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateHighlighted];
    [_leftButton addTarget:self action:@selector(jumpToMallPosition:) forControlEvents:UIControlEventTouchUpInside];
    [_leftButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_leftButton.layer setCornerRadius:2.5];
    [_leftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.view addSubview:_leftButton];
    
    _rightButton = [[UIButton alloc]init];
    _rightButton.backgroundColor = [UIColor colorWithString:@"ebebeb" alpha:0.2];
    [_rightButton setTitle:@"楼层地图" forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor colorWithString:@"e5e5e5"] forState:UIControlStateNormal];
    [_rightButton setImage:[UIImage imageNamed:@"mall_img_floor"] forState:UIControlStateNormal];
    [_rightButton setImage:[UIImage imageNamed:@"mall_img_floor"] forState:UIControlStateHighlighted];
    [_rightButton setBackgroundImage:[UIImage imageNamed:@"shop_bg_2_pr"] forState:UIControlStateHighlighted];
    [_rightButton addTarget:self action:@selector(jumpToFloorMap:) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_rightButton.layer setCornerRadius:2.5];
    [_rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.view addSubview:_rightButton];

//放置8个button
    _categoryView = [[UIView alloc]init];
    _categoryView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    _categoryView.clipsToBounds = YES;
    _categorys = [YTCategory newAllCategorys];
        for (int i = 0; i < _categorys.count; i++) {
            UIButton *categoryBtn = [[UIButton alloc]initWithFrame:CGRectMake(15 + i % 4 * 80, 12 + i / 4  * 93, 50, 50)];
            YTCategory *category = _categorys[i];
            [categoryBtn setImage:category.image forState:UIControlStateNormal];
            [categoryBtn addTarget:self action:@selector(jumpToCategory:) forControlEvents:UIControlEventTouchUpInside];
            categoryBtn.tag = i;
            [_categoryView addSubview:categoryBtn];
            
            UILabel *categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(categoryBtn.frame) + 7, 50, 20)];
            categoryLabel.center = CGPointMake(categoryBtn.center.x, categoryLabel.center.y);
            categoryLabel.text = category.text;
            categoryLabel.tintColor = [UIColor colorWithString:@"808080"];
            categoryLabel.textAlignment = 1;
            categoryLabel.font = [UIFont systemFontOfSize:14];
            [_categoryView addSubview:categoryLabel];
        }
    [_scrollView addSubview:_categoryView];
    
//categoryView尺寸控制按钮
    _scrollButton = [[UIButton alloc]init];
    _scrollButton.backgroundColor = [UIColor whiteColor];
    [_scrollButton setImage:[UIImage imageNamed:@"icon_h"] forState:UIControlStateNormal];
    [_scrollButton setImage:[UIImage imageNamed:@"icon_up"] forState:UIControlStateSelected];
    [_scrollButton addTarget:self action:@selector(addCategory:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_scrollButton];
    
    _adView = [[YTadScrollAndPageView alloc]init];
    _adView.backgroundColor = [UIColor whiteColor];
    [_adView shouldAutoShow:YES];
    _adView.delegate = self;
    [_scrollView addSubview:_adView];
    _adView.hidden = YES;
    
    _activityImgView = [[UIImageView alloc]init];
    _activityImgView.image = [UIImage imageNamed:@"flag_zhu"];
    [_scrollView addSubview:_activityImgView];
    _activityImgView.hidden = YES;

    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = false;
    _tableView.rowHeight = ROW_HEIGHT;
    _tableView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_scrollView addSubview:_tableView];
    
    [_mall existenceOfPreferentialInformationQueryMall:^(BOOL isExistence) {
        if (isExistence) {
            
            _saleView = [[UIView alloc]init];
            _saleView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
            
            UIImage *titleImage = [UIImage imageNamed:@"title_disco"];
            UIImageView *titleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, titleImage.size.width, titleImage.size.height)];
            titleImageView.image = titleImage;
            titleImageView.tag = 10;
            [_saleView addSubview:titleImageView];
            
            UIButton *more = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 100, 0, 100, 35)];
            [more setTitle:@"更多" forState:UIControlStateNormal];
            [more setTitleColor:[UIColor colorWithString:@"e95e37"] forState:UIControlStateNormal];
            [more.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [more setImage:[UIImage imageNamed:@"icon_arrow_orange"] forState:UIControlStateNormal];
            [more setImageEdgeInsets:UIEdgeInsetsMake(0, 66, 0, 0)];
            [more addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
            [_saleView addSubview:more];
            [_scrollView addSubview:_saleView];
            
            for (NSInteger index = 0;index < 3;index++){
                YTSaleView *saleView = [[YTSaleView alloc]initWithFrame:CGRectMake(index * (CGRectGetWidth(self.view.frame) / 3), CGRectGetMaxY(titleImageView.frame), CGRectGetWidth(self.view.frame) / 3, 130)];
                saleView.delegate = self;
                saleView.tag = index;
                saleView.tag = index;
                [_saleView addSubview:saleView];
            }
        }
    }];
    
    [_scrollView addSubview:_stateView];
    
    [self getHot];
    [self getSale];
    [self getActivity];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
}

- (void)viewWillLayoutSubviews{
    CGRect frame = _leftButton.frame;
    frame.origin.x = 8;
    frame.origin.y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    frame.size.width = 148;
    frame.size.height = 44;
    _leftButton.frame = frame;
    
    frame = _rightButton.frame;
    frame.origin.x = CGRectGetMaxX(_leftButton.frame) + 8;
    frame.origin.y = CGRectGetMinY(_leftButton.frame);
    frame.size.width = CGRectGetWidth(_leftButton.frame);
    frame.size.height = CGRectGetHeight(_leftButton.frame);
    _rightButton.frame = frame;
    
    frame = _scrollView.frame;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(_leftButton.frame) + 8;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = CGRectGetHeight(self.view.frame) - frame.origin.y;
    _scrollView.frame = frame;
    
    frame = _categoryView.frame;
    frame.origin = CGPointZero;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = 101;
    _categoryView.frame = frame;
    
    frame = _scrollButton.frame;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(_categoryView.frame);
    frame.size.width = CGRectGetWidth(_categoryView.frame);
    frame.size.height = 15.0;
    _scrollButton.frame = frame;
    
    frame = _adView.frame;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(_scrollButton.frame) + 10;
    frame.size.width = CGRectGetWidth(_scrollView.frame);
    frame.size.height = 130;
    _adView.frame = frame;
    
    frame = _activityImgView.frame;
    frame.origin.x = CGRectGetWidth(_adView.frame) - 55.0;
    frame.origin.y = CGRectGetMaxY(_scrollButton.frame) +10;
    frame.size.width = 55.0;
    frame.size.height = 55.0;
    _activityImgView.frame = frame;
    
    if (_adView.hidden ==YES && _activityImgView.hidden == YES) {
        frame = _saleView.frame;
        frame.origin.x = 0;
        frame.origin.y = CGRectGetMaxY(_scrollButton.frame) + 10;
        //frame.origin.y = _adView != nil ? CGRectGetMaxY(_adView.frame) + 10: CGRectGetMaxY(_scrollButton.frame) + 10;
        frame.size.width = CGRectGetWidth(_scrollView.frame);
        frame.size.height = 165;
        _saleView.frame = frame;
        
        frame = _tableView.frame;
        frame.origin.x = 0;
        frame.origin.y = _saleView != nil ? CGRectGetMaxY(_saleView.frame) + 10:CGRectGetMaxY(_scrollButton.frame) + 10;
        frame.size.width = CGRectGetWidth(self.view.frame) + 10;
        frame.size.height = ROW_HEIGHT * 10 + HEAD_HEIGHT;
        _tableView.frame = frame;
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(_tableView.frame));
    }
}


#pragma mark
#pragma mark NavigationBar Handle
- (void)defaultNavigationBar{
    if (!_leftBarButton) {
        _leftBarButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
        [_leftBarButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [_leftBarButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
        [_leftBarButton setImage:[UIImage imageNamed:@"icon_backOn"] forState:UIControlStateHighlighted];
    }
    
    if (!_rightBarButton) {
        _rightBarButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
        [_rightBarButton addTarget:self action:@selector(jumpToSearch:) forControlEvents:UIControlEventTouchUpInside];
        [_rightBarButton setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
        [_rightBarButton setImage:[UIImage imageNamed:@"icon_searchOn"] forState:UIControlStateHighlighted];
    }
    self.navigationItem.hidesBackButton = true;
    self.navigationItem.title = [_mall mallName];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_leftBarButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_rightBarButton];
    self.navigationController.navigationBar.clipsToBounds = true;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
}

- (void)back:(UIButton *)sender{
    [_searchView removeFromSuperview];
    [self.navigationController popViewControllerAnimated:true];
}

- (void)jumpToSearch:(UIButton *)sender{
    [_searchView showSearchViewWithAnimation:YES];
}

#pragma mark
#pragma mark Custom method

- (void)getHot{
    AVQuery *query = [AVQuery queryWithClassName:@"Merchant"];
    [query whereKeyExists:@"Icon"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *hotMerchants = [NSMutableArray new];
            for (AVObject *object in objects) {
                YTCloudMerchant *merchant = [[YTCloudMerchant alloc]initWithAVObject:object];
                [hotMerchants addObject:merchant];
            }
            _hots = hotMerchants.copy;
            [_tableView reloadData];
            [hotMerchants removeAllObjects];
            hotMerchants = nil;
            [self checkAnimationisStop];
        }else{
            _stateView.type = YTStateTypeNoNetWork;
        }
    }];
}

- (void)getActivity{
    AVQuery *mallQuery = [AVQuery queryWithClassName:@"Mall"];
    [mallQuery whereKey:@"objectId" equalTo:[_mall identifier]];
    AVQuery *query = [AVQuery queryWithClassName:@"MallActivity"];
    [query whereKey:@"mall" matchesQuery:mallQuery];
    query.limit = 5;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count > 0) {
            NSMutableArray *adMallImg = [NSMutableArray new];
            for (AVObject *object in objects) {
                YTMallActivity *activity = [[YTMallActivity alloc]initWithCloudObject:object];
                [activity getActivityImgWithCallBack:^(UIImage *result, NSError *error) {
                    if (!error) {
                        UIImageView *imageView = [[UIImageView alloc] init];
                        imageView.image = result;
                        [adMallImg addObject:imageView];
                    }
                }];
            }
            _activityImgView.hidden = NO;
            _adView.hidden = NO;
            [_adView setImgArr:adMallImg];
            if (_activityImgView.hidden ==NO && _adView.hidden == NO) {
                CGRect frame = _saleView.frame;
                frame = _saleView.frame;
                frame.origin.x = 0;
                frame.origin.y = _adView != nil ? CGRectGetMaxY(_adView.frame) + 10: CGRectGetMaxY(_scrollButton.frame) + 10;
                frame.size.width = CGRectGetWidth(_scrollView.frame);
                frame.size.height = 165;
                _saleView.frame = frame;
                
                frame = _tableView.frame;
                frame.origin.x = 0;
                frame.origin.y = _saleView != nil ? CGRectGetMaxY(_saleView.frame) + 10:CGRectGetMaxY(_adView.frame) + 10;
                frame.size.width = CGRectGetWidth(self.view.frame) + 10;
                frame.size.height = ROW_HEIGHT * 10 + HEAD_HEIGHT;
                _tableView.frame = frame;
                _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(_tableView.frame));

            }
        }
    }];
}

- (void)getSale{
    AVQuery *mallQuery = [AVQuery queryWithClassName:@"Mall"];
    [mallQuery whereKey:@"objectId" equalTo:[_mall identifier]];
    AVQuery *query = [AVQuery queryWithClassName:@"PreferentialInformation"];
    query.limit = 3;
    [query whereKey:@"switch" equalTo:@YES];
    [query whereKey:@"mall" matchesQuery:mallQuery];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *preferentials = [NSMutableArray array];
            for (AVObject *object in objects) {
                YTPreferential *preferential = [[YTPreferential alloc]initWithCloudObject:object];
                [preferentials addObject:preferential];
            }
            if (preferentials.count < 3) {
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                [manager GET:@"http://xiaguang.avosapps.com/coupon" parameters:@{@"count":[NSNumber numberWithInteger:3 - preferentials.count],@"mallId":[_mall identifier]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if (responseObject) {
                        NSArray *objects = responseObject;
                        for (NSDictionary *object in objects) {
                            YTPreferential *preferential = [[YTPreferential alloc]initWithDaZhongDianPing:object];
                            [preferentials addObject:preferential];
                        }
                        _sales = preferentials.copy;
                        [self reloadSaleData];
                        [self checkAnimationisStop];
                    }else{
                        if (_stateView.type != YTStateTypeNoNetWork) {
                            _stateView.type = YTStateTypeNoNetWork;
                        }
                    }
                } failure:nil];
            }
        }else{
            _stateView.type = YTStateTypeNoNetWork;
        }
    }];

    
}

- (void)checkAnimationisStop{
    if (_hots && _sales) {
        _loadingTime -= [[NSDate date]timeIntervalSinceReferenceDate];
        
        dispatch_time_t time;
        if (_loadingTime < 2) {
            time = dispatch_time(DISPATCH_TIME_NOW,NSEC_PER_SEC);
        }else{
            time = dispatch_time(DISPATCH_TIME_NOW, 0);
        }
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [_stateView stopAnimation];
            [_stateView removeFromSuperview];
            _scrollView.scrollEnabled = true;
        });
    }
}

- (void)reloadSaleData{
    [_saleView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[YTSaleView class]] && [(UIView *)obj tag] <= _sales.count - 1) {
            YTSaleView *saleView = obj;
            YTPreferential *preferential = _sales[saleView.tag];
            [preferential getMerchantInstanceWithCallBack:^(YTCloudMerchant *merchant) {
                if (merchant) {
                    [merchant getThumbNailWithCallBack:^(UIImage *result, NSError *error) {
                        if (!error) {
                            [saleView setSaleViewWithMerchantImage:result merchantName:[merchant merchantName] saleInfo:[preferential preferentialInfo] isSole:[preferential type]];
                        }
                    }];
                }
            }];
        }
    }];
}

#pragma mark
#pragma mark Button Method
- (void)jumpToMallPosition:(UIButton *)sender{
    if (_poisitionViewController){
        [self.navigationController pushViewController:_poisitionViewController animated:YES];
    }
}

-(void)more:(UIButton *)sender{
    YTResultsViewController *resultVC = [[YTResultsViewController alloc]initWithPreferntialInMall:_mall];
    [self.navigationController pushViewController:resultVC animated:true];
}

- (void)jumpToFloorMap:(UIButton *)sender{
    id <YTFloor> floor = nil;
    YTLocalMall *localmall = [_mallDict changeMallObject:_mall resultType:YTMallClassLocal];
    if (localmall == nil){
        [[[YTMessageBox alloc]initWithTitle:@"" Message:@"很抱歉，该商城地图还未下载，请前往地图管理中下载地图" cancelButtonTitle:@"确定"] show];
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
//button跳转页面
-(void)jumpToCategory:(UIButton *)sender{
    YTCategory *category = _categorys[sender.tag];
    if (sender.tag == _categorys.count - 1) {
        YTMoreCategoryViewController *moreVC = [[YTMoreCategoryViewController alloc]init];
        moreVC.mall = _mall;
        moreVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:moreVC animated:YES];
    }else{
        YTResultsViewController *resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:_mall andResutsKey:category.text];
        [self.navigationController pushViewController:resultsVC animated:YES];
    }
}

// scrollButton点击触发功能
- (void)addCategory:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected == YES) {
        CGRect frame = _scrollView.frame;
        frame.origin.x = 0;
        frame.origin.y = CGRectGetMaxY(_leftButton.frame) + 8;
        frame.size.width = CGRectGetWidth(self.view.frame);
        frame.size.height = CGRectGetHeight(self.view.frame) - frame.origin.y;
        _scrollView.frame = frame;
        
        frame = _categoryView.frame;
        frame.origin = CGPointZero;
        frame.size.width = CGRectGetWidth(self.view.frame);
        frame.size.height = 190;
        _categoryView.frame = frame;
        
        frame = _scrollButton.frame;
        frame.origin.x = 0;
        frame.origin.y = CGRectGetMaxY(_categoryView.frame);
        frame.size.width = CGRectGetWidth(_categoryView.frame);
        frame.size.height = 15.0;
        _scrollButton.frame = frame;
        
        frame = _adView.frame;
        frame.origin.x = 0;
        frame.origin.y = CGRectGetMaxY(_scrollButton.frame) + 10;
        frame.size.width = CGRectGetWidth(_scrollView.frame);
        frame.size.height = 130;
        _adView.frame = frame;
        
        frame = _activityImgView.frame;
        frame.origin.x = CGRectGetWidth(_adView.frame) - 55.0;
        frame.origin.y = CGRectGetMaxY(_scrollButton.frame) +10;
        frame.size.width = 55.0;
        frame.size.height = 55.0;
        _activityImgView.frame = frame;
        
        if (_adView.hidden == YES && _activityImgView.hidden == YES) {
            frame = _saleView.frame;
            frame.origin.x = 0;
            frame.origin.y = CGRectGetMaxY(_scrollButton.frame) + 10;
            frame.size.width = CGRectGetWidth(_scrollView.frame);
            frame.size.height = 165;
            _saleView.frame = frame;
            
            frame = _tableView.frame;
            frame.origin.x = 0;
            frame.origin.y = _saleView != nil ? CGRectGetMaxY(_saleView.frame) + 10:CGRectGetMaxY(_scrollButton.frame) + 10;
            frame.size.width = CGRectGetWidth(self.view.frame) + 10;
            frame.size.height = ROW_HEIGHT * 10 + HEAD_HEIGHT;
            _tableView.frame = frame;
            _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(_tableView.frame));

        }else if (_adView.hidden ==NO  && _activityImgView.hidden == NO) {
            frame = _saleView.frame;
            frame.origin.x = 0;
            frame.origin.y = CGRectGetMaxY(_adView.frame) + 10;
            frame.size.width = CGRectGetWidth(_scrollView.frame);
            frame.size.height = 165;
            _saleView.frame = frame;
            
            frame = _tableView.frame;
            frame.origin.x = 0;
            frame.origin.y = _saleView != nil ? CGRectGetMaxY(_saleView.frame) + 10:CGRectGetMaxY(_adView.frame) + 10;
            frame.size.width = CGRectGetWidth(self.view.frame) + 10;
            frame.size.height = ROW_HEIGHT * 10 + HEAD_HEIGHT;
            _tableView.frame = frame;
            _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(_tableView.frame));

        }
        
    } else if (sender.selected == NO) {
        CGRect frame = _scrollView.frame;
        frame.origin.x = 0;
        frame.origin.y = CGRectGetMaxY(_leftButton.frame) + 8;
        frame.size.width = CGRectGetWidth(self.view.frame);
        frame.size.height = CGRectGetHeight(self.view.frame) - frame.origin.y;
        _scrollView.frame = frame;
        
        frame = _categoryView.frame;
        frame.origin = CGPointZero;
        frame.size.width = CGRectGetWidth(self.view.frame);
        frame.size.height = 101;
        _categoryView.frame = frame;
        
        frame = _scrollButton.frame;
        frame.origin.x = 0;
        frame.origin.y = CGRectGetMaxY(_categoryView.frame);
        frame.size.width = CGRectGetWidth(_categoryView.frame);
        frame.size.height = 15.0;
        _scrollButton.frame = frame;
        
        frame = _adView.frame;
        frame.origin.x = 0;
        frame.origin.y = CGRectGetMaxY(_scrollButton.frame) + 10;
        frame.size.width = CGRectGetWidth(_scrollView.frame);
        frame.size.height = 130;
        _adView.frame = frame;
        
        frame = _activityImgView.frame;
        frame.origin.x = CGRectGetWidth(_adView.frame) - 55.0;
        frame.origin.y = CGRectGetMaxY(_scrollButton.frame) +10;
        frame.size.width = 55.0;
        frame.size.height = 55.0;
        _activityImgView.frame = frame;
        
        if (_adView.hidden == YES && _activityImgView.hidden == YES) {
            frame = _saleView.frame;
            frame.origin.x = 0;
            frame.origin.y = CGRectGetMaxY(_scrollButton.frame) + 10;
            frame.size.width = CGRectGetWidth(_scrollView.frame);
            frame.size.height = 165;
            _saleView.frame = frame;
            
            frame = _tableView.frame;
            frame.origin.x = 0;
            frame.origin.y = _saleView != nil ? CGRectGetMaxY(_saleView.frame) + 10:CGRectGetMaxY(_scrollButton.frame) + 10;
            frame.size.width = CGRectGetWidth(self.view.frame) + 10;
            frame.size.height = ROW_HEIGHT * 10 + HEAD_HEIGHT;
            _tableView.frame = frame;
            _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(_tableView.frame));
            
        }else if (_adView.hidden ==NO  && _activityImgView.hidden == NO) {
            frame = _saleView.frame;
            frame.origin.x = 0;
            frame.origin.y = CGRectGetMaxY(_adView.frame) + 10;
            frame.size.width = CGRectGetWidth(_scrollView.frame);
            frame.size.height = 165;
            _saleView.frame = frame;
            
            frame = _tableView.frame;
            frame.origin.x = 0;
            frame.origin.y = _saleView != nil ? CGRectGetMaxY(_saleView.frame) + 10:CGRectGetMaxY(_adView.frame) + 10;
            frame.size.width = CGRectGetWidth(self.view.frame) + 10;
            frame.size.height = ROW_HEIGHT * 10 + HEAD_HEIGHT;
            _tableView.frame = frame;
            _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(_tableView.frame));
            
        }

    }
    
    
}

- (void)touchEndWithSaleView:(YTSaleView *)saleView{
    YTPreferential *preferential = _sales[saleView.tag];
    [preferential getMerchantInstanceWithCallBack:^(YTCloudMerchant *merchant) {
        if (merchant == nil){
            return ;
        }
        [_dataManager saveMerchantInfo:merchant];
        YTMerchantInfoViewController *merchantInfoVC = [[YTMerchantInfoViewController alloc]initWithMerchant:merchant];
        [self.navigationController pushViewController:merchantInfoVC animated:YES];
    }];
}


#pragma mark
#pragma mark SearchView Handle
- (void)selectedUniIds:(NSArray *)uniIds{
    YTResultsViewController *resultsVC = [[YTResultsViewController alloc]initWithSearchInMall:_mall andResultsLocalDBIds:uniIds];
    [self.navigationController pushViewController:resultsVC animated:YES];
}

#pragma mark
#pragma mark TableView Handle
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMerchantViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMerchantCellIdentify];
    if (!cell) {
        cell = [[YTMerchantViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMerchantCellIdentify];
        cell.titleColor = [UIColor colorWithString:@"333333"];
        cell.backgroundColor = [UIColor clearColor];
    }
    if (_hots && _hots.count > 0) {
        cell.merchant = _hots[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    YTMerchantViewCell *cell = (YTMerchantViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.merchant){
        [_dataManager saveMerchantInfo:cell.merchant];
        YTMerchantInfoViewController *merchantInfoVC = [[YTMerchantInfoViewController alloc]initWithMerchant:cell.merchant];
        [self.navigationController pushViewController:merchantInfoVC animated:YES];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *background = [[UIView alloc]init];
    UIImage *hotImage = [UIImage imageNamed:@"title_hotbrand"];
    UIImageView *hotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, hotImage.size.width, 27)];
    hotImageView.image = hotImage;
    [background addSubview:hotImageView];
    return background;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 36;
}
#pragma mark
#pragma mark Remove searchView else memory leak or viewController not destruction
- (void)dealloc{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSURLCache sharedURLCache]removeAllCachedResponses];
    });
}
@end