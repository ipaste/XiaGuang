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
#import "YTPreferential.h"
#import "YTCategory.h"
#import "MJRefresh.h"
#import "YTMerchantInfoViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"

typedef NS_ENUM(NSUInteger, YTResultsType) {
    YTResultsTypePreferential,
    YTResultsTypeResults
};
@interface YTResultsViewController ()<UITableViewDelegate,UITableViewDataSource,YTCategoryResultsDelegete,DPRequestDelegate>{
    NSString *_category;
    NSString *_subCategory;
    NSString *_merchantName;
    NSString *_mallUniId;
    NSString *_floorUniId;
    UILabel *_notLabel;
    NSArray *_ids;
    NSMutableArray *_merchants;
    id<YTMall> _mall;
    BOOL _isCategory;
    BOOL _isSubCategory;
    BOOL _isLoading;
    BOOL _isFirst;
    UITableView *_tableView;
    YTCategoryResultsView *_categoryResultsView;
    YTResultsType _type;
    NSInteger _dealCount;
}
@end

@implementation YTResultsViewController

-(instancetype)initWithPreferntialInMall:(id <YTMall>)mall{
    self = [super init];
    if (self) {
        _mallUniId = [mall localDB];
        _type = YTResultsTypePreferential;
    }
    return self;
}

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
        
        if(_mall){
            _mallUniId = [mall localDB];
        }
        _type = YTResultsTypeResults;
        
    }
    return self;
}

-(instancetype)initWithSearchInMall:(id<YTMall>)mall andResultsLocalDBIds:(NSArray *)ids{
    self = [super init];
    if (self) {
        _mall = mall;
        _mallUniId = [mall localDB];
        _ids = ids;
        _type = YTResultsTypeResults;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_type == YTResultsTypePreferential) {
        self.navigationItem.title = @"更多优惠";
    }else{
        self.navigationItem.title = @"搜索结果";
    }
   
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shop_bg_1"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
    
    _isFirst = YES;
    
    _dealCount = 0;
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    _tableView.delegate = self;
    
    _tableView.dataSource = self;
    
    _tableView.backgroundColor = [UIColor clearColor];
    
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
    
    if (_type != YTResultsTypePreferential){
        _categoryResultsView = [[YTCategoryResultsView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40) andmall:_mall categoryKey:_category subCategory:_subCategory];
        _categoryResultsView.delegate = self;
        [self.view addSubview:_categoryResultsView];
        
    }
    
    [self getMerchantsWithSkip:0  numbers:10  andBlock:^(NSArray *merchants) {
        if (merchants != nil) {
            _merchants = [NSMutableArray arrayWithArray:merchants];
            if (!_isCategory) {
                id<YTMerchant> tmpMerchant = [merchants firstObject];
                _subCategory = [[tmpMerchant type] lastObject];
                _category = [[tmpMerchant type] firstObject];
                
            }
            [_categoryResultsView setKey:_category subKey:_subCategory];
        }
        [self reloadData];
    }];
    
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
    
    CGFloat topHeight = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    if (_type != YTResultsTypePreferential) {
        CGRect frame = _tableView.frame;
        frame.origin.y = topHeight + 40;
        frame.size.height = CGRectGetHeight(self.view.frame) - topHeight - 40;
        _tableView.frame = frame;
        
        frame = _categoryResultsView.frame;
        frame.origin.y = topHeight;
        _categoryResultsView.frame = frame;
    }else{
        
        CGRect frame = _tableView.frame;
        frame.origin.y = topHeight;
        frame.size.height = frame.size.height - topHeight;
        _tableView.frame = frame;
    }
}

-(UIView *)leftBarButton{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 35, 20, 20, 20)];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_backOn"] forState:UIControlStateHighlighted];
    return button;
}

-(void)back:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)pullToRefresh{
    if (!_isLoading) {
        _isLoading = YES;
        [self getMerchantsWithSkip:(int)_merchants.count numbers:10 andBlock:^(NSArray *merchants) {
            if (merchants.count > 0) {
                [_merchants addObjectsFromArray:merchants];
                [self reloadData];
            }
            [_tableView footerEndRefreshing];
            _isLoading = NO;
        }];
    }
}

-(void)getMerchantsWithSkip:(int)skip numbers:(int)number andBlock:(void (^)(NSArray *merchants))block{
    NSMutableArray *merchants = [NSMutableArray array];
    if (_type == YTResultsTypeResults) {
        AVQuery *query = [AVQuery queryWithClassName:MERCHANT_CLASS_NAME];
        [query orderByAscending:@"name"];
        [query includeKey:@"mall,floor"];
        if (_mall) {
            AVQuery *mallquery = [AVQuery queryWithClassName:@"Mall"];
            [mallquery whereKey:MALL_CLASS_LOCALID equalTo:_mallUniId];
            [query whereKey:@"mall" matchesQuery:mallquery];
        }
        query.limit = number;
        query.skip = skip;
        if (_isCategory) {
            if (_subCategory != nil) {
                [query whereKey:MERCHANT_CLASS_TYPE_KEY containsString:_subCategory];
            }else{
                if (_category != nil){
                    [query whereKey:MERCHANT_CLASS_TYPE_KEY containsString:_category];
                }
            }
        }else{
            if (_ids.count <= 0 || _ids == nil) {
                block(nil);
                return;
            }
            [query whereKey:MERCHANT_CLASS_UNIID_KEY containedIn:_ids];
        }
        
        if (_floorUniId != nil) {
            AVQuery *floorObject = [AVQuery queryWithClassName:@"Floor"];
            [floorObject whereKey:@"uniId" equalTo:_floorUniId];
            [query whereKey:@"floor" matchesQuery:floorObject];
        }
        
        if (_mallUniId != nil) {
            AVQuery *mallObject = [AVQuery queryWithClassName:@"Mall"];
            [mallObject whereKey:@"localDBId" equalTo:_mallUniId];
            [query whereKey:@"mall" matchesQuery:mallObject];
        }
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if(error){
                block(nil);
                return;
            }
            
            for (AVObject *merchantObject in objects) {
                YTCloudMerchant *merchant = [[YTCloudMerchant alloc]initWithAVObject:merchantObject];
                [merchants addObject:merchant];
            }
            
            block(merchants);
            return ;
        }];
    }else{
        AVQuery *query = [AVQuery queryWithClassName:@"PreferentialInformation"];
        [query includeKey:@"merchant"];
        query.limit = number;
        query.skip = skip;
        AVQuery *mallObject = [AVQuery queryWithClassName:@"Mall"];
        [mallObject whereKey:@"localDBId" equalTo:_mallUniId];
        [query whereKey:@"mall" matchesQuery:mallObject];
        [query whereKey:@"switch" equalTo:@YES];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                block(nil);
            }else{
                for (AVObject *preferential in objects) {
                    YTPreferential *tmpPreferential = [[YTPreferential alloc]initWithCloudObject:preferential];
                    [tmpPreferential getMerchantInstanceWithCallBack:^(YTCloudMerchant *merchant) {
                       [merchants addObject:merchant];
                    }];
                }
                if(merchants.count < number){
                    AVQuery *merchantQuery = [AVQuery queryWithClassName:@"Merchant"];
                    [merchantQuery whereKey:@"has_deal" equalTo:@YES];
                    [merchantQuery whereKey:@"mall" matchesQuery:mallObject];
                    merchantQuery.limit = number - merchants.count;
                    merchantQuery.skip = _dealCount;
                    [merchantQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        for (AVObject *object in objects) {
                            YTCloudMerchant *merchant = [[YTCloudMerchant alloc]initWithAVObject:object];
                            [merchants addObject:merchant];
                        }
                        _dealCount = _dealCount + (number - merchants.count);
                        block(merchants);
                    }];
                }
            }
        }];
        
    }
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
        
        cell.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    }
    
    id <YTMerchant> merchant = _merchants[indexPath.row];
    
    cell.merchant = merchant;
    
    return cell;
}

-(void)reloadData{
    [_tableView reloadData];
    if (_merchants.count == 0 || _merchants == nil) {
        _notLabel.hidden = NO;
    }else{
        _notLabel.hidden = YES;
    }
}
-(void)searchKeyForCategoryTitle:(NSString *)category subCategoryTitle:(NSString *)subCategory mallUniId:(NSString *)malluniId floorUniId:(NSString *)floorUniId{
    [_merchants removeAllObjects];
    [_tableView reloadData];
    NSLog(@"category:%@  subCategory:%@ mallUniId:%@ floorUniId:%@",category,subCategory,malluniId,floorUniId);
    
    _subCategory = subCategory;
    
    if ([category isEqualToString:@"全部"]) {
        _category = nil;
    }else{
        _category = category;
    }
    if ([subCategory isEqualToString:@"全部"]) {
        _subCategory = nil;
    }else{
        _subCategory = subCategory;
    }
    _mallUniId = malluniId;
    _floorUniId = floorUniId;
    _isCategory = YES;
    
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
