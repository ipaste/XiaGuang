//
//  YTResultsViewController.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTResultsViewController.h"
#import "YTMerchantViewCell.h"
#import <AVObject.h>
#import <AVQuery.h>
#import "YTCloudMerchant.h"
#import "YTCloudMall.h"
#import "YTCategoryResultsView.h"
#import "YTCategory.h"
#import "MJRefresh.h"
#import "YTMerchantInfoViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@interface YTResultsViewController ()<UITableViewDelegate,UITableViewDataSource,YTCategoryResultsDelegete>{
    NSString *_category;
    NSString *_subCategory;
    NSString *_merchantName;
    NSString *_mallName;
    NSString *_floorName;
    UILabel *_notLabel;
    NSMutableArray *_merchants;
    id<YTMall> _mall;
    BOOL _isCategory;
    BOOL _isSubCategory;
    BOOL _isLoading;
    BOOL _isFirst;
    UITableView *_tableView;
    YTCategoryResultsView *_categoryResultsView;
}
@end

@implementation YTResultsViewController
-(id)initWithSearchInMall:(id<YTMall>)mall andResutsKey:(NSString *)key{
    return [self initWithSearchInMall:mall andResutsKey:key andSubKey:nil];
}

-(id)initWithSearchInMall:(id<YTMall>)mall andResutsKey:(NSString *)key andSubKey:(NSString *)subKey{
    self = [super init];
    if (self) {
        _mall = mall;
        if (subKey == nil) {
            for (YTCategory *category  in [YTCategory allCategorys]) {
                if ([key isEqualToString:category.text]) {
                    _category = key;
                    _subCategory = nil;
                    _isCategory = true;
                    break;
                }
            }
        }else{
            _category = key;
            _subCategory = subKey;
            _isCategory = true;
        }
        if(!_isCategory){
            _merchantName = key;
        }
        if(_mall){
            _mallName = [mall mallName];
        }
        _isFirst = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"搜索结果";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"all_bg_navbar-1"] forBarMetrics:UIBarMetricsDefault];
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    _tableView.delegate = self;
    
    _tableView.dataSource = self;
    
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];
    
    _tableView.tableFooterView = [[UIView alloc]init];
    
    _tableView.showsVerticalScrollIndicator = NO;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView addFooterWithTarget:self action:@selector(pullToRefresh)];
    
    [self.view addSubview:_tableView];
    
    
    _notLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,100, CGRectGetWidth(self.view.frame), 45)];
    _notLabel.font = [UIFont systemFontOfSize:20];
    _notLabel.textColor = [UIColor colorWithString:@"c8c8c8"];
    _notLabel.text = @"无结果";
    _notLabel.textAlignment = 1;
    _notLabel.hidden = YES;
    [_tableView addSubview:_notLabel];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];
    
    _categoryResultsView = [[YTCategoryResultsView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40) andmall:_mall categoryKey:_category subCategory:_subCategory];
    _categoryResultsView.delegate = self;
    [self.view addSubview:_categoryResultsView];
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_isFirst) {
        _isFirst = NO;
        [self getMerchantsWithSkip:0  numbers:10  andBlock:^(NSArray *merchants) {
            _merchants = [NSMutableArray arrayWithArray:merchants];
            if (_merchantName != nil) {
                for (id<YTMerchant> merchant in merchants) {
                    _subCategory = [[merchant type] lastObject];
                    _category = [[merchant type] firstObject];
                }
            }
            [_categoryResultsView setKey:_category subKey:_subCategory];
            [self reloadData];
        }];
        
    }
}
-(void)viewWillLayoutSubviews{
    CGFloat topHeight = [self.topLayoutGuide length];
    
    CGRect frame = _tableView.frame;
    frame.origin.y = topHeight + 40;
    frame.size.height = CGRectGetHeight(self.view.frame) - topHeight - 40;
    _tableView.frame = frame;
    /*
     if (_merchantName == nil) {
     frame.origin.y = topHeight + 40;
     frame.size.height = CGRectGetHeight(self.view.frame) - topHeight - 40;
     }else{
     frame.origin.y = topHeight;
     frame.size.height = CGRectGetHeight(self.view.frame) - topHeight ;
     }
     */
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    frame = _categoryResultsView.frame;
    frame.origin.y = topHeight;
    _categoryResultsView.frame = frame;
    
}


-(void)pullToRefresh{
    
    if (!_isLoading) {
        _isLoading = YES;
        [self getMerchantsWithSkip:(int)_merchants.count numbers:10 andBlock:^(NSArray *merchants) {
            [_merchants addObjectsFromArray:merchants];
            [self reloadData];
            [_tableView footerEndRefreshing];
            _isLoading = NO;
        }];
    }
}

-(void)getMerchantsWithSkip:(int)skip numbers:(int)number andBlock:(void (^)(NSArray *merchants))block{
    NSMutableArray *merchants = [NSMutableArray array];
    NSString *whereKey = _isCategory ? MERCHANT_CLASS_TYPE_KEY : MERCHANT_CLASS_NAME_KEY;
    
    AVQuery *query = [AVQuery queryWithClassName:MERCHANT_CLASS_NAME];
    [query orderByAscending:@"name"];
    
    query.limit = number;
    query.skip = skip;
    if (_isCategory) {
        if (_subCategory != nil) {
            [query whereKey:whereKey containsString:_subCategory];
        }else{
            if (_category != nil){
                [query whereKey:whereKey containsString:_category];
            }
        }
    }else{
        [query whereKey:whereKey equalTo:_merchantName];
    }
    if (_floorName != nil) {
        AVQuery *floorQuery = [AVQuery queryWithClassName:@"Floor"];
        [floorQuery whereKey:@"floorName" equalTo:_floorName];
        [query whereKey:@"floor" equalTo:[floorQuery getFirstObject]];
    }
    
    if (_mallName != nil) {
        AVQuery *mallObject = [AVQuery queryWithClassName:@"Mall"];
        [mallObject whereKey:@"name" equalTo:_mallName];
        [query whereKey:@"mall" equalTo:[mallObject getFirstObject]];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (AVObject *merchantObject in objects) {
            YTCloudMerchant *merchant = [[YTCloudMerchant alloc]initWithAVObject:merchantObject];
            [merchants addObject:merchant];
        }
        
        block(merchants);
        return ;
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _merchants.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YTMerchantViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[YTMerchantViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    id <YTMerchant> merchant = _merchants[indexPath.row];
    
    cell.merchant = merchant;
    
    return cell;
}

-(void)reloadData{
    [_tableView reloadData];
    if (_merchants.count == 0) {
        _notLabel.hidden = NO;
    }else{
        _notLabel.hidden = YES;
    }
}

-(void)searchKeyForCategoryTitle:(NSString *)category subCategoryTitle:(NSString *)subCategory mallName:(NSString *)mallName floor:(NSString *)floorName{
    [_merchants removeAllObjects];
    [_tableView reloadData];
    //#warning 加载动画
    NSLog(@"category:%@  subCategory:%@ mallName:%@ floorName:%@",category,subCategory,mallName,floorName);
    _category = category;
    _subCategory = subCategory;
    _floorName = floorName;
    _mallName = mallName;
    if ([_category isEqualToString:@"全部"]) {
        _category = nil;
    }
    if ([_subCategory isEqualToString:@"全部"]) {
        _subCategory = nil;
    }
    
    if ([_floorName isEqualToString:@"全部"]){
        _floorName = nil;
    }
    
    if ([_mallName isEqualToString:@"全部"]){
        _mallName = nil;
    }
    
    [self getMerchantsWithSkip:0 numbers:10 andBlock:^(NSArray *merchants) {
        _merchants = [NSMutableArray arrayWithArray:merchants];
        [self reloadData];
    }];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YTMerchantViewCell *cell = (YTMerchantViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    id<YTMerchant> merchant = _merchants[indexPath.row];
    YTMerchantInfoViewController *merchantInfoVC = [[YTMerchantInfoViewController alloc]initWithMerchant:merchant];
    [self.navigationController pushViewController:merchantInfoVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

-(void)dealloc{
    NSLog(@"ResultsDealloc");
}
@end
