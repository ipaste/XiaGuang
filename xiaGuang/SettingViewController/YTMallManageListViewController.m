//
//  YTMallManageListViewController.m
//  虾逛
//
//  Created by Nov_晓 on 15/4/20.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//
#import "YTMallManageListViewController.h"

#define SCROLL_HEIGHT 40.0f
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface YTMallManageListViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *_cells;
    NSArray *_allCells;
    YTMallDict *_mallDict;
}

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *lineView;
@property (nonatomic,retain)NSMutableArray *regions;
@end

@implementation YTMallManageListViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    YTCity *defaultCity = [YTCity defaultCity];
    _cells = [NSMutableArray array];
    _mallDict = [YTMallDict sharedInstance];

    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0, CGRectGetMaxY(self.navigationController.navigationBar.frame),CGRectGetWidth(self.view.frame) , SCROLL_HEIGHT)];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor colorWithString:@"f0f0f0"];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    _regions = [NSMutableArray new];
    [_regions addObject:@"全城"];
    CGFloat width = defaultCity.regions.count + 1 > 6 ? SCREEN_WIDTH / 6:SCREEN_WIDTH / (defaultCity.regions.count + 1);
    for (NSInteger index = 0; index < defaultCity.regions.count + 1; index++) {
        UIButton *regionButton = [[UIButton alloc]init];
        regionButton.frame = CGRectMake(width * index, 0, width, CGRectGetHeight(self.scrollView.frame));
        regionButton.backgroundColor = [UIColor clearColor];
        regionButton.tag = index;
        [regionButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [regionButton setTitleColor:[UIColor colorWithString:@"666666"] forState:UIControlStateNormal];
        [regionButton setTitleColor:[UIColor colorWithString:@"e95e37"] forState:UIControlStateSelected];
        [regionButton addTarget:self action:@selector(clickSwitchRegion:) forControlEvents:UIControlEventTouchUpInside];
        if (index == 0){
            [regionButton setTitle:_regions[index] forState:UIControlStateNormal];
        }else{
            YTRegion *region = defaultCity.regions[index - 1];
            [regionButton setTitle:region.name forState:UIControlStateNormal];
            [_regions addObject:region];
        }
        [_scrollView addSubview:regionButton];
    }
    _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(_scrollView.frame) - 2, width, 2.0f)];
    _lineView.backgroundColor = [UIColor colorWithString:@"e95e37"];
    [_scrollView addSubview:_lineView];
    
    
    [_mallDict getAllCloudMallWithCallBack:^(NSArray *malls) {
        for (YTCloudMall *mall in malls) {
            YTMallmanageCell *cell = [[YTMallmanageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            cell.mall = mall;
            [_cells addObject:cell];
        }
        _allCells = _cells.copy;
        [_tableView reloadData];
    }];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(_scrollView.frame))];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    [self.view addSubview:_tableView];
    
    
    //关闭scrollView往下偏移的功能
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = @"商城地图列表";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _cells[indexPath.row];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[_tableView deselectRowAtIndexPath:indexPath animated:false];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}
- (void)clickSwitchRegion:(UIButton *)sender{
    CGRect frame = _lineView.frame;
    frame.origin.x = CGRectGetMinX(sender.frame);
    _lineView.frame = frame;
    
    if (sender.tag == 0) {
        _cells = [NSMutableArray arrayWithArray:_allCells];
        [_tableView reloadData];
    }else{
        YTRegion *region = _regions[sender.tag];
        _cells = [NSMutableArray new];
        NSArray *malls = [_mallDict cloudMallsFromRegion:region];
        [malls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            YTCloudMall *mall = obj;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.mall == %@",mall];
            YTMallmanageCell *tmpCell = [_allCells filteredArrayUsingPredicate:predicate].firstObject;
            if (tmpCell != nil) {
                [_cells addObject:tmpCell];
            }
            if (idx == malls.count - 1) {
                [_tableView reloadData];
            }
        }];

    }
}

//返回按钮
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
