//
//  YTMallManageListViewController.m
//  虾逛
//
//  Created by Nov_晓 on 15/4/20.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//
#define scrollH 40.0f
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#import "YTMallManageListViewController.h"


@interface YTMallManageListViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *lineView;

@property (nonatomic,retain)NSMutableArray *nameArr;

@end

@implementation YTMallManageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    YTCity *defaultCity = [YTCity defaultCity];
    AVQuery *query = [AVQuery queryWithClassName:@"Region"];
    [query whereKey:@"cityId" equalTo:[NSNumber numberWithInteger:defaultCity.identify]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        float xOffset = 0;
        _nameArr = [NSMutableArray new];
        
        for (int index = 0;index < objects.count; index++) {
            //NSInteger tag = index - 1;
            UIButton *mallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            mallBtn.backgroundColor = [UIColor clearColor];
            mallBtn.tag = 100 + index;
            mallBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            mallBtn.frame = CGRectMake(xOffset, 0, SCREEN_WIDTH / 6, CGRectGetHeight(self.scrollView.frame));
            [mallBtn setTitleColor:[UIColor colorWithString:@"666666"] forState:UIControlStateNormal];
            [mallBtn setTitleColor:[UIColor colorWithString:@"e95e37"] forState:UIControlStateSelected];
            //            if (tag == -1) {
            //                mallBtn.selected = YES;
            //                [mallBtn setTitle:@"全城" forState:UIControlStateNormal];
            //            }else{
            YTRegion *region = [[YTRegion alloc]initWithCloudObject:objects[index]];
            [mallBtn setTitle:region.name forState:UIControlStateNormal];
            [_nameArr addObject:region];
            //            }
            xOffset += mallBtn.frame.size.width+ 44.0 ;
            _scrollView.contentSize = CGSizeMake(xOffset, scrollH);
            //[mallBtn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:mallBtn];
            
        }
    }];
    
    _selectedTabID = 100;
    float contentH = 0;
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"商城管理列表";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
    
    //关闭scrollView往下移动的功能
    self.automaticallyAdjustsScrollViewInsets = NO;
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0, CGRectGetMaxY(self.navigationController.navigationBar.frame),CGRectGetWidth(self.view.frame) , scrollH)];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor colorWithString:@"f0f0f0"];
    _scrollView.showsHorizontalScrollIndicator =NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    
    
    contentH += CGRectGetMaxY(_scrollView.frame);
    
    _lineView = [[UIView alloc]initWithFrame:CGRectMake(0.0, CGRectGetHeight(_scrollView.frame) - 2.0f, SCREEN_WIDTH /6, 2.0f)];
    _lineView.backgroundColor = [UIColor colorWithString:@"e95e37"];
    [_scrollView addSubview:_lineView];
    
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0, contentH, SCREEN_WIDTH, SCREEN_HEIGHT - contentH)];
    _mainScrollView.backgroundColor = [UIColor colorWithString:@"b2b2b2"];
    _mainScrollView.delegate = self;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_mainScrollView];
    
    _mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * _nameArr.count, SCREEN_HEIGHT - contentH);
    for (int i =0; i<_nameArr.count; i++) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * i, 1.0, SCREEN_WIDTH, SCREEN_HEIGHT - contentH - 1.0) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
        [_mainScrollView addSubview:_tableView];

    }
    
   
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _nameArr.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static  NSString *cellIdentifier = @"cellIdetifier";
    YTMallmanageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (!cell) {
        cell = [[YTMallmanageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

//cell背景色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:0.85];
    
}
/*
// btn 点击触发
- (void)selectBtn: (UIButton *)sender {
    switch (sender.tag) {
        case -1:
            
            break;
        default:
            YTRegion *region = _nameArr[sender.tag];
            
            break;
    }
    if (sender.tag != _selectedTabID) {
        UIButton *preButton = (UIButton *)[_scrollView viewWithTag:_selectedTabID];
        preButton.selected = NO;
        _selectedTabID = sender.tag;
        
        if (sender.tag == 100 ) {
            [_scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        }
        else if (sender.tag == 101) {
            self.isLeft = NO;
            [_scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        }
        else if (sender.tag == 106) {
            self.isLeft = YES;
            [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH / 6, 0.0) animated:YES];
        }
        else if (sender.tag == 102) {
            self.isLeft = YES;
            if (_scrollView.contentOffset.x == 0.0) {
                [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH / 6, 0.0) animated:YES];
                self.isLeft = YES;
            }
            else {
                [_scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
                self.isLeft = YES;
            }
        } else {
            [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH / 6, 0.0) animated:YES];
        }
        [UIView animateWithDuration:0.25 animations:^{
            _lineView.frame = CGRectMake(sender.frame.origin.x, _lineView.frame.origin.y, sender.frame.size.width, _lineView.frame.size.height);
        }];
    }
    
    if (!sender.selected) {
        sender.selected = YES;
        [_mainScrollView setContentOffset:CGPointMake((sender.tag - 100) * SCREEN_WIDTH, 0) animated:YES];
        [UIView animateWithDuration:0.25 animations:^{
            _lineView.frame = CGRectMake(sender.frame.origin.x, _lineView.frame.origin.y, sender.frame.size.width, _lineView.frame.size.height);
        }];
    }

    
    [_tableView reloadData];
}*/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _scrollView) {
        //[self changeBtnFont:scrollView.contentOffset.x];
        
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
