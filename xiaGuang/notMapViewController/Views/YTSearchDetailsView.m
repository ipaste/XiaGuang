//
//  YTSearchEntranceView.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-15.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTSearchDetailsView.h"
#import <AVObject.h>
#import <AVQuery.h>
#import "Reachability.h"
#import "YTCloudMerchant.h"
#import "YTResultsViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTFileManager.h"
#define HISTORYTABLECELL_HEIGHT 40
@interface YTSearchDetailsView()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    YTFileManager *_fileManager;
    id<YTMall> _mall;
    UIView *_hotSearchView;
    UILabel *_notLabel;
    UIScrollView *_scrollView;
    UITableView *_searchResultstableView;
    UITableView *_historyTableView;
    NSMutableArray *_results;
    NSArray *_historicalRecord;
    NSArray *_popularMerchants;
}
@end
@implementation YTSearchDetailsView
-(id)initWithFrame:(CGRect)frame andDataSourceMall:(id<YTMall>)mall{
    self = [super initWithFrame:frame];
    if (self) {
        _mall = mall;
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)+ 10);
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        
        _hotSearchView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame), 128)];
        [_hotSearchView addSubview:[self headLabelWithText:@"热门搜索" indent:25]];
        
        AVQuery *query = [AVQuery queryWithClassName:@"Merchant"];
        
        if (mall) {
            AVQuery *mallQuery = [AVQuery queryWithClassName:@"Mall"];
            [mallQuery whereKey:@"name" equalTo:[mall mallName]];
            [query whereKey:@"mall" matchesQuery:mallQuery];
        }
        
        query.limit = 6;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            _popularMerchants = [NSArray arrayWithArray:objects];
            
            for (int i = 0 ; i < objects.count; i++) {
                AVObject *object = objects[i];
                id<YTMerchant> merchant = [[YTCloudMerchant alloc]initWithAVObject:object];
                UIButton *hotButton = [[UIButton alloc]initWithFrame:CGRectMake(25  + i % 3 * 95 , 45 + i / 3 * 40, 85, 30)];
                [hotButton setTitle:[merchant shortName] forState:UIControlStateNormal];
                [hotButton setTitleColor:[UIColor colorWithString:@"606060"] forState:UIControlStateNormal];
                [hotButton setBackgroundImage:[UIImage imageNamed:@"search_btn_un"] forState:UIControlStateNormal];
                [hotButton setBackgroundImage:[UIImage imageNamed:@"search_btn_pr"] forState:UIControlStateHighlighted];
                [hotButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [hotButton addTarget:self action:@selector(jumpToMerchant:) forControlEvents:UIControlEventTouchUpInside];
                hotButton.tag  = i;
                [_hotSearchView addSubview:hotButton];
            }
        }];
        
        
        
        [_scrollView addSubview:_hotSearchView];
        
        _fileManager = [YTFileManager defaultManager];
        
        _historyTableView = [[UITableView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_hotSearchView.frame), CGRectGetWidth(_scrollView.frame) , _historicalRecord.count * HISTORYTABLECELL_HEIGHT + 35) style:UITableViewStylePlain];
        _historyTableView.backgroundColor = [UIColor clearColor];
        _historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _historyTableView.delegate = self;
        _historyTableView.dataSource = self;
        _historyTableView.scrollEnabled = NO;
        [_scrollView addSubview:_historyTableView];
        
        _searchResultstableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)) style:UITableViewStylePlain];
        _searchResultstableView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        _searchResultstableView.delegate = self;
        _searchResultstableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchResultstableView.dataSource = self;
        _searchResultstableView.hidden = YES;
        [self addSubview:_searchResultstableView];
        
        _notLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,100, CGRectGetWidth(_searchResultstableView.frame), 45)];
        _notLabel.font = [UIFont systemFontOfSize:20];
        _notLabel.textColor = [UIColor colorWithString:@"c8c8c8"];
        _notLabel.text = @"无结果";
        _notLabel.textAlignment = 1;
        _notLabel.hidden = YES;
        [_searchResultstableView addSubview:_notLabel];
        self.hidden = YES;
    }
    return self;
    
}
-(void)searchWithKeyword:(NSString *)keyWord{
    if (keyWord.length <= 0) {
        _searchResultstableView.hidden = YES;
        _scrollView.hidden = NO;
        return;
    }

    //关键字处理
    _scrollView.hidden = YES;
    _searchResultstableView.hidden = NO;
    if (_results != nil) {
        [_results removeAllObjects];
        [_searchResultstableView reloadData];
    }
    _results = [NSMutableArray array];
    FMDatabase *db = [YTStaticResourceManager sharedManager].db;
    FMResultSet *result = nil;
    if (_mall) {
       result = [db executeQuery:@"select * from MerchantInstance where merchantInstanceName like ? and ",[NSString stringWithFormat:@"%%%@%%",keyWord]];
    }else{
        result = [db executeQuery:@"select distinct merchantInstanceName from MerchantInstance"];
    }
    
    while ([result next]) {
        YTLocalMerchantInstance *tmpMerchant = [[YTLocalMerchantInstance alloc]initWithDBResultSet:result];
        [_results addObject:tmpMerchant];
    }
    
    [_searchResultstableView reloadData];
    
    if (_results.count > 0) {
        _searchResultstableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _searchResultstableView.separatorColor = [UIColor colorWithString:@"c8c8c8"];
        _notLabel.hidden = YES;
    }else{
        _searchResultstableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _notLabel.hidden = NO;
    }
//    AVQuery *query = [AVQuery queryWithClassName:@"Merchant"];
//    query.limit = 10;
//    
//    [query includeKey:@"mall,floor.block.mall"];
//    if (_mall) {
//        AVQuery *mallQuery = [AVQuery queryWithClassName:@"Mall"];
//        [mallQuery whereKey:@"name" equalTo:[_mall mallName]];
//        [query whereKey:@"mall" matchesQuery:mallQuery];
//    }
//
//    [query whereKey:@"name" matchesRegex:keyWord modifiers:@"i"];
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//       
//        for (AVObject *merchantObject in objects) {
//            YTCloudMerchant *merchant = [[YTCloudMerchant alloc]initWithAVObject:merchantObject];
//
//            [_results addObject:merchant];
//        }
//        [_searchResultstableView reloadData];
//        if (_results.count > 0) {
//            _searchResultstableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//            _searchResultstableView.separatorColor = [UIColor colorWithString:@"c8c8c8"];
//            _notLabel.hidden = YES;
//        }else{
//            _searchResultstableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//            _notLabel.hidden = NO;
//        }
//    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:_historyTableView]) {
        _historicalRecord = [_fileManager readDataWithFileName:@"history"];
        
        CGRect frame = _historyTableView.frame;
        if (_historicalRecord.count > 0) {
            frame.size.height = _historicalRecord.count * HISTORYTABLECELL_HEIGHT + 35;
        }else{
            frame.size.height = 1 * HISTORYTABLECELL_HEIGHT + 35;
        }
        _historyTableView.frame = frame;
        
        if (_historicalRecord.count <= 0) {
            return 1;
        }
        return _historicalRecord.count;
        
    }
    
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIView *selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectZero];
    selectedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"all_bg_8%black"]];
    
    if ([tableView isEqual:_historyTableView]) {
        UITableViewCell *historycell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
        if (!historycell) {
            historycell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"historyCell"];
            historycell.backgroundColor = [UIColor clearColor];
            historycell.textLabel.textColor = [UIColor colorWithString:@"606060"];
            historycell.textLabel.font = [UIFont systemFontOfSize:14];
            historycell.textLabel.frame = CGRectMake(25, 0, CGRectGetWidth(historycell.frame) - 25, HISTORYTABLECELL_HEIGHT);
            historycell.selectedBackgroundView = selectedBackgroundView;

        }
        if (_historicalRecord.count <= 0) {
            historycell.textLabel.text = @"暂无历史";
            historycell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else{
            historycell.textLabel.text = _historicalRecord[indexPath.row];
        }
        return historycell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
            cell.backgroundColor = [UIColor clearColor];
            
            cell.selectedBackgroundView = selectedBackgroundView;
    
            cell.textLabel.textColor = [UIColor colorWithString:@"606060"];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.tag = 0;

            cell.detailTextLabel.textColor = [UIColor colorWithString:@"dcdcdc"];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
            cell.detailTextLabel.textAlignment = 2;
            cell.detailTextLabel.tag = 1;

            
        }
        
        id<YTMerchantLocation> merchant = _results[indexPath.row];
        NSString *merchantName = [merchant merchantLocationName];
        NSString *remarks = [NSString stringWithFormat:@"%@ %@ %@",[[merchant floor] floorName],[[[merchant floor] block] blockName],[[merchant mall] mallName]];
/*
        CGFloat merchantNameWidth = [merchantName boundingRectWithSize:CGSizeMake(200, 44) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.width;

        CGRect frame = cell.te.frame;
        frame.size.width = merchantNameWidth;
        label.frame = frame;
        
        frame = subLabel.frame;
        frame.origin.x = CGRectGetMaxX(label.frame) + 5;
        frame.size.width = CGRectGetWidth(self.frame) - CGRectGetWidth(label.frame) - 35;
        subLabel.frame = frame;
     */
        cell.textLabel.text = merchantName;
        cell.detailTextLabel.text = remarks;
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([tableView isEqual:_historyTableView]) {
        if (_historicalRecord.count <= 0){
            return;
        }
        [self.delegate selectSearchResultsWithMerchantnName:_historicalRecord[indexPath.row]];
        
    }else if([tableView isEqual:_searchResultstableView]){
        NSMutableArray *history = [NSMutableArray arrayWithArray:[_fileManager readDataWithFileName:@"history"]];
        
        if (history.count >= 8) {
            [history removeObjectAtIndex:history.count - 1];
        }
        
        if (_results.count > 0) {
            id<YTMerchant> merchant = _results[indexPath.row];
            [history insertObject:[merchant merchantName] atIndex:0];
            [_fileManager saveWithData:history andCreateFileName:@"history"];
            [_historyTableView reloadData];
            _scrollView.hidden = NO;
            _searchResultstableView.hidden = YES;
            [self.delegate selectSearchResultsWithMerchantnName:[merchant merchantName]];
        }
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_historyTableView]) {
        return HISTORYTABLECELL_HEIGHT;
    }
    return 45;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([tableView isEqual:_historyTableView]) {
        return 35;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([tableView isEqual:_historyTableView]) {
        UIView *background = [[UIView alloc]init];
        background.backgroundColor = [UIColor clearColor];
        [background addSubview:[self headLabelWithText:@"搜索历史" indent:10]];
        return background;
    }
    return nil;
}
-(UIView *)headLabelWithText:(NSString *)text indent:(CGFloat)indentX{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(indentX, 0, CGRectGetWidth(_scrollView.frame) - 25, 33)];
    label.backgroundColor = [UIColor clearColor];
    
    label.text = text;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor colorWithString:@"e95e37"];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame), CGRectGetWidth(label.frame), 0.5)];
    line.backgroundColor = [UIColor colorWithString:@"e95e37"];
    [label addSubview:line];
    return label;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    [self.delegate cancelSearchInput];
}

-(void)jumpToMerchant:(UIButton *)sender{
    NSInteger index = sender.tag;
    AVObject *tmp = [_popularMerchants objectAtIndex:index];
    NSString *merchantName = tmp[@"name"];
    [self.delegate selectSearchResultsWithMerchantnName:merchantName];
}
-(void)dealloc{
    [_results removeAllObjects];
    NSLog(@"searchDetails dealloc");
}

@end
