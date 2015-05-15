//
//  YTActiveDetailViewController.m
//  虾逛
//
//  Created by Yuntop on 15/5/14.
//  Copyright (c) 2015年 YunTop. All rights reserved.
//

#import "YTActiveDetailViewController.h"
#import "YTActiveDetailCell.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface YTActiveDetailViewController ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView *_mainTableView;
    UIImageView *_imgView;
    YTStateView *_stateView;
    NSMutableArray *_activityImages;
    NSTimeInterval _loadingTime;
}

@end

@implementation YTActiveDetailViewController
- (instancetype)init{
    self = [super init];
    if (self) {
        _activityImages = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainTableView = [[UITableView alloc]init];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    [_mainTableView setBackgroundColor:[UIColor clearColor]];
    _mainTableView.separatorColor = [UIColor colorWithString:@"e5e5e5"];
    _mainTableView.separatorInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    _mainTableView.showsVerticalScrollIndicator = NO;
    
    _stateView = [[YTStateView alloc]init];
    _stateView.type = YTStateTypeLoading;
    [_stateView startAnimation];
    
    [self.view addSubview:_mainTableView];
    [self.view addSubview:_stateView];
    
    self.navigationItem.title = @"活动详情";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[self leftBarButton]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithString:@"e65e37"] forKey:NSForegroundColorAttributeName]];
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_inner.jpg"].CGImage;
    self.automaticallyAdjustsScrollViewInsets = false;
}

- (void)viewWillLayoutSubviews{
    CGRect frame  = _mainTableView.frame;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = CGRectGetHeight(self.view.frame) - frame.origin.y;
    _mainTableView.frame = frame;
    
    frame = _stateView.frame;
    frame.origin.y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    frame.size.height = CGRectGetHeight(self.view.frame) - frame.origin.y;
    _stateView.frame = frame;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _activityImages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell addSubview:_activityImages[indexPath.row]];

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImageView *imageView = _activityImages[indexPath.row];
    
    return CGRectGetHeight(imageView.frame);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setSelectedActivity:(NSInteger)selectedActivity{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedActivity inSection:0];
    [_mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:true];
    _selectedActivity = selectedActivity;
}

- (void)setActivitys:(NSArray *)activitys{
    _loadingTime = [[NSDate date] timeIntervalSinceReferenceDate];
    __block NSInteger count = 0;
    for (YTMallActivity *activity in activitys) {
        [activity getActivityDetailWithCallBack:^(UIImage *detailImage, NSError *error) {
            count++;
            if (detailImage != nil){
                CGFloat scale = detailImage.size.width / CGRectGetWidth(self.view.frame);
                CGFloat pw = detailImage.size.width / scale;
                CGFloat ph = detailImage.size.height / scale;
                UIImageView *imageView = [[UIImageView alloc]initWithImage:detailImage];
                imageView.frame = CGRectMake(0, 0, pw, ph);
                [_activityImages addObject:imageView];
            }
            
            if (count == activitys.count) {
                dispatch_time_t time =  dispatch_time(DISPATCH_TIME_NOW, 0);
                if ([[NSDate date]timeIntervalSinceReferenceDate] - _loadingTime < 2) time = dispatch_time(DISPATCH_TIME_NOW,NSEC_PER_SEC);
                dispatch_after(time, dispatch_get_main_queue(), ^{
                    [_mainTableView reloadData];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectedActivity inSection:0];
                    [_mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:false];
                    [_stateView stopAnimation];
                    [_stateView removeFromSuperview];
                });
            }
        }];
    }
    _activitys = activitys;
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

-(void)dealloc{
    NSLog(@"ActiveDetailDealloc");
}


@end
