//
//  YTSwitchMallView.m
//  虾逛
//
//  Created by YunTop on 14/11/14.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTSwitchMallView.h"
#define DEFAULT_HEIGHT 120
#define DEFAULT_TABLEVIEW_HEIGHT 4 * (CGRectGetHeight(_downPullButton.frame) - 10)
@implementation YTSwitchMallView{
    CGRect _screenFrame;
    
    UIView *_backgroundView;
    
    UIButton *_downPullButton;
    
    UILabel *_promptLabel;
    
    UITableView *_pullTableView;
    
    NSMutableArray *_malls;
    
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _screenFrame =  [UIScreen mainScreen].bounds;
        
        _malls = [NSMutableArray array];
        
        FMDatabase *dbBase = [YTDBManager sharedManager].db;
        FMResultSet *result = [dbBase executeQuery:@"select * from Mall"];
        
        while ([result next]) {
            YTLocalMall *tmpMall = [[YTLocalMall alloc]initWithDBResultSet:result];
            [_malls addObject:tmpMall];
        }
        
        self.frame = CGRectMake(50, 0, CGRectGetWidth(_screenFrame) - 100, DEFAULT_HEIGHT);
        
        _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [self addSubview:_backgroundView];
        
        _downPullButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 15, CGRectGetWidth(self.frame) - 20, 45)];
        [_downPullButton addTarget:self action:@selector(downpullButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_downPullButton];
        
        _pullTableView = [[UITableView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_downPullButton.frame) - 10, CGRectGetWidth(_downPullButton.frame),DEFAULT_TABLEVIEW_HEIGHT) style:UITableViewStylePlain];
        _pullTableView.delegate = self;
        _pullTableView.dataSource = self;
        _pullTableView.backgroundColor = [UIColor clearColor];
        _pullTableView.showsVerticalScrollIndicator = NO;
        
        [self downpullButtonClicked];
        
        [self insertSubview:_pullTableView belowSubview:_downPullButton];
        
        if ([_pullTableView respondsToSelector:@selector(setSeparatorInset:)]){
            [_pullTableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([[UIDevice currentDevice].systemVersion hasPrefix:@"8"] && [_pullTableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_pullTableView setLayoutMargins:UIEdgeInsetsZero];
        }
        
        self.center = CGPointMake(CGRectGetWidth(_screenFrame) / 2, CGRectGetHeight(_screenFrame) / 2 - 25);
    }
    return self;
}


-(void)layoutSubviews{
    _backgroundView.layer.cornerRadius = 10;
    _backgroundView.backgroundColor = [UIColor colorWithString:@"000000" alpha:0.7];
    
    _downPullButton.backgroundColor = [UIColor colorWithString:@"505050"];
    _downPullButton.layer.cornerRadius = 5;
    [_downPullButton setTitleColor:[UIColor colorWithString:@"ffffff"] forState:UIControlStateNormal];
    _downPullButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _downPullButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [_downPullButton setImage:[UIImage imageWithImageName:@"type_pulldownArrow" andTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_downPullButton setImage:[UIImage imageFromImage:[UIImage imageWithImageName:@"type_pulldownArrow" andTintColor:[UIColor whiteColor]] rotate:M_PI] forState:UIControlStateSelected];
    [_downPullButton setImageEdgeInsets:UIEdgeInsetsMake(0, CGRectGetWidth(_downPullButton.frame) - 30, 0, 0)];
    
    _pullTableView.layer.cornerRadius = 5;
}

-(void)downpullButtonClicked{
    _downPullButton.selected = !_downPullButton.selected;
    if (_downPullButton.selected){ //选择
        CGRect frame = self.frame;
        frame.size.height = CGRectGetMaxY(_pullTableView.frame);
        self.frame = frame;
        
        [UIView animateWithDuration:.2 animations:^{
            CGRect frame = _pullTableView.frame;
            frame.size.height = DEFAULT_TABLEVIEW_HEIGHT;
            _pullTableView.frame = frame;
        }];
        
    }else{ //取消选择
        CGRect frame = self.frame;
        frame.size.height = DEFAULT_HEIGHT;
        self.frame = frame;
        
        [UIView animateWithDuration:.2 animations:^{
            CGRect frame = _pullTableView.frame;
            frame.size.height = 0;
            _pullTableView.frame = frame;
        }];
    }
}

-(void)setMall:(id<YTMall>)mall{
    [_downPullButton setTitle:[mall mallName] forState:UIControlStateNormal];
    _mall = mall;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _malls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *tmpCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!tmpCell) {
        tmpCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        tmpCell.backgroundColor = [UIColor colorWithString:@"606060"];
        tmpCell.textLabel.textColor = [UIColor colorWithString:@"f1f1f1"];
        tmpCell.textLabel.font = [UIFont systemFontOfSize:16];
        
        }
    tmpCell.textLabel.text = [_malls[indexPath.row] mallName];
    return tmpCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor blackColor];
    
    [self downpullButtonClicked];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    cell.textLabel.textColor = [UIColor whiteColor];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return  10;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CGRectGetHeight(_downPullButton.frame) - 5;
}
@end
