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
#import "YTCloudMerchant.h"
#import "YTResultsViewController.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
#import "YTFileManager.h"
#import "YTChineseTool.h"
#define HISTORYTABLECELL_HEIGHT 40
#define HOTSEARCH_HEIGTH 148
@interface YTSearchDetailsView()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    YTFileManager *_fileManager;
    id<YTMall> _mall;
    UIView *_hotSearchView;
    UILabel *_notLabel;
    UIScrollView *_scrollView;
    UITableView *_searchResultstableView;
    UITableView *_historyTableView;
    NSMutableArray *_results;
    NSMutableArray *_unIds;
    NSArray *_recordObjects;
    NSString *_majorAreaIds;
    NSArray *_popularMerchants;
    NSOperationQueue *_searchOpQueue;
    UIView *_selectView;
    UIButton *_notNetWordButton;
    NSMutableArray *_pinyingSearchSource;
    BOOL _isRefrest;
}
@end
@implementation YTSearchDetailsView
-(id)initWithFrame:(CGRect)frame andDataSourceMall:(id<YTMall>)mall{
    self = [super initWithFrame:frame];
    if (self) {
        _results = [NSMutableArray array];
        _unIds = [NSMutableArray array];
        _searchOpQueue = [[NSOperationQueue alloc] init];
        _searchOpQueue.maxConcurrentOperationCount = 1;
        _mall = mall;
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor colorWithString:@"f0f0f0" alpha:1.0];
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)+ 10);
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        _selectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), HISTORYTABLECELL_HEIGHT)];
        _hotSearchView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame), HOTSEARCH_HEIGTH)];
        [_hotSearchView addSubview:[self headLabelWithText:@"热门搜索" indent:20]];
        
        _notNetWordButton = [[UIButton alloc]initWithFrame:CGRectMake(0, HOTSEARCH_HEIGTH / 2 - 15, CGRectGetWidth(self.frame), 30)];
        [_notNetWordButton addTarget:self action:@selector(refreshHotSearch) forControlEvents:UIControlEventTouchUpInside];
        [_notNetWordButton setTitle:@"连接网络，点击刷新" forState:UIControlStateNormal];
        [_notNetWordButton setTitleColor:[UIColor colorWithString:@"999999"] forState:UIControlStateNormal];
        _notNetWordButton.hidden = true;
        [_hotSearchView addSubview:_notNetWordButton];
        [self getHotSearch];
        [_scrollView addSubview:_hotSearchView];
        
        
        _fileManager = [YTFileManager defaultManager];
        
        [self setHistoricalRecordNames:[_fileManager readDataWithFileName:@"history"]];
        
        NSInteger count = _recordObjects.count == 0 ? 1:_recordObjects.count;
        
        _historyTableView = [[UITableView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_hotSearchView.frame), CGRectGetWidth(_scrollView.frame) , count * HISTORYTABLECELL_HEIGHT + 35) style:UITableViewStylePlain];
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
        
        _majorAreaIds = [self getMajorAreaId:_mall];
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            FMDatabase *db = [YTDataManager defaultDataManager].database;
//            _pinyingSearchSource = [NSMutableArray array];
//            if (_majorAreaIds != nil){
//                FMResultSet *results = [db executeQuery:@"select distinct merchantInstanceName from merchantInstance where majo rArea in ? ",_majorAreaIds];
//                while ([results next]) {
//                    [_pinyingSearchSource addObject:[results stringForColumnIndex:0]];
//                }
//            }else{
//                FMResultSet *results = [db executeQuery:@"select distinct merchantInstanceName from merchantInstance"];
//                while ([results next]) {
//                    [_pinyingSearchSource addObject:[results stringForColumnIndex:0]];
//                }
//            }
//            
//        });
        
    }
    return self;
    
}
-(void)searchWithKeyword:(NSString *)keyWord{
    
    if (keyWord.length <= 0) {
        _searchResultstableView.hidden = YES;
        _scrollView.hidden = NO;
        return;
    }else{
        _scrollView.hidden = YES;
        _searchResultstableView.hidden = NO;
    }
    NSRange range = [keyWord rangeOfString:@"'"];
    
    if (range.length > 0 ) {
        [self updateUI:@{@"uniIds":@[],@"merchants":@[]}];
        return;
    }
   
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
    
        if(op.isCancelled){
            NSLog(@"cancelled op so we don't search");
            return;
        }
        FMDatabase *db = [YTDataManager defaultDataManager].database;
        FMResultSet *result = nil;
        if (_mall) {
            NSString *sql = [NSString stringWithFormat:@"select * from MerchantInstance where merchantInstanceName like %@ COLLATE NOCASE and uniId != 0 and merchantInstanceId in (select max(merchantInstanceId) from MerchantInstance where majorAreaId in %@ group by MerchantInstanceName)",[NSString stringWithFormat:@"'%%%@%%'",keyWord],_majorAreaIds];
            
            result = [db executeQuery:sql];
        }else{
            NSString *sql = [NSString stringWithFormat:@"select * from MerchantInstance where merchantInstanceName like %@ COLLATE NOCASE and uniId != 0 and merchantInstanceId in (select max(merchantInstanceId) from MerchantInstance group by MerchantInstanceName)",[NSString stringWithFormat:@"'%%%@%%'",keyWord]];
            result = [db executeQuery:sql];
        }
        NSMutableArray *results = [NSMutableArray array];
        NSMutableArray *uniIds = [NSMutableArray array];
        
        while ([result next]) {
            YTLocalMerchantInstance *tmpMerchant = [[YTLocalMerchantInstance alloc]initWithDBResultSet:result];
            
            [results addObject:tmpMerchant];
            
            [uniIds addObject:[self merchantsWithMerchantName:[tmpMerchant merchantLocationName]]];
        }
        NSDictionary *resultDict = @{@"merchants":results,@"uniIds":uniIds};
        if(!op.cancelled){
            NSLog(@"cancelled op so we don't callback");
            [self performSelectorOnMainThread:@selector(updateUI:) withObject:resultDict waitUntilDone:YES];
        }
        
        
    }];
    
    [_searchOpQueue cancelAllOperations];
    [_searchOpQueue addOperation:op];
}



-(void)updateUI:(NSDictionary *)resultFromOperation{
    _unIds = resultFromOperation[@"uniIds"];
    _results = resultFromOperation[@"merchants"];
    [_searchResultstableView reloadData];
    
    if (_results.count > 0) {
        _searchResultstableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _searchResultstableView.separatorColor = [UIColor colorWithString:@"c8c8c8"];
        _notLabel.hidden = YES;
    }else{
        _searchResultstableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _notLabel.hidden = NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:_historyTableView]) {
        if (_recordObjects.count <= 0) {
            return 1;
        }
        return _recordObjects.count;
    }
    
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIView *selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectZero];
    selectedBackgroundView.backgroundColor = [UIColor colorWithString:@"000000" alpha:0.06];
    
    if ([tableView isEqual:_historyTableView]) {
        UITableViewCell *historycell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
        if (!historycell) {
            historycell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"historyCell"];
            historycell.backgroundColor = [UIColor clearColor];
            historycell.textLabel.textColor = [UIColor colorWithString:@"666666"];
            historycell.textLabel.font = [UIFont systemFontOfSize:14];
            historycell.textLabel.frame = CGRectMake(15, 0, CGRectGetWidth(historycell.frame) - 25, HISTORYTABLECELL_HEIGHT);
            selectedBackgroundView.frame = CGRectMake(0, 0, CGRectGetWidth(historycell.frame), HISTORYTABLECELL_HEIGHT);
            historycell.selectedBackgroundView = selectedBackgroundView;
            
        }
        if (_recordObjects.count <= 0) {
            historycell.textLabel.textColor = [UIColor colorWithString:@"999999"];
            historycell.textLabel.text = @"暂无历史";
            historycell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else{
            
            id<YTMerchantLocation> tmpMerchantInstance = _recordObjects[indexPath.row];
            historycell.textLabel.text = [tmpMerchantInstance merchantLocationName];
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
        NSString *remarks = [NSString stringWithFormat:@"总共搜索到%ld家",[_unIds[indexPath.row] count]];
        cell.textLabel.text = merchantName;
        cell.detailTextLabel.text = remarks;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([tableView isEqual:_historyTableView]) {
        if (_recordObjects.count <= 0){
            return;
        }
        
        id<YTMerchantLocation> tmpMerchantLocation = _recordObjects[indexPath.row];
        [self.delegate selectSearchResultsWithUniIds:[self merchantsWithMerchantName:[tmpMerchantLocation merchantLocationName]]];
        
    }else if([tableView isEqual:_searchResultstableView]){
        NSMutableArray *history = [NSMutableArray arrayWithArray:[_fileManager readDataWithFileName:@"history"]];
        
        if (history.count >= 8) {
            [history removeObjectAtIndex:history.count - 1];
        }
        
        if (_results.count > 0) {
            id<YTMerchantLocation> tmpMerchantLocation = _results[indexPath.row];
            [history insertObject:[tmpMerchantLocation merchantLocationName] atIndex:0];
            [_fileManager saveWithData:history andCreateFileName:@"history"];
            [self setHistoricalRecordNames:history];
            [_historyTableView reloadData];
            _scrollView.hidden = NO;
            _searchResultstableView.hidden = YES;
            [self.delegate selectSearchResultsWithUniIds:_unIds[indexPath.row]];
        }
    }
    
}

-(void)searchButtonClicked{
    if (_results.count > 0) {
        [self tableView:_searchResultstableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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
        return 22;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([tableView isEqual:_historyTableView]) {
        UIView *background = [[UIView alloc]init];
        background.backgroundColor = [UIColor clearColor];
        [background addSubview:[self headLabelWithText:@"历史纪录" indent:10]];
        return background;
    }
    
    return nil;
}
-(UIView *)headLabelWithText:(NSString *)text indent:(CGFloat)indentX{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(indentX, 0, 295, 21)];
    if ([text isEqualToString:@"热门搜索"]) {
        imageView.image = [UIImage imageNamed:@"title_hot"];
    }else{
        imageView.image = [UIImage imageNamed:@"title_history"];
    }
    return imageView;
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
    NSString *merchantId = tmp[@"uniId"];
    [self.delegate selectSearchResultsWithUniIds:@[merchantId]];
}

-(NSString *)getMajorAreaId:(YTLocalMall *)aMall{
    if (aMall == nil){
        return nil;
    }
    FMDatabase *db = [YTDataManager defaultDataManager].database;
    FMResultSet *result = [db executeQuery:@"select * from MajorArea where mallId = ?",aMall.identifier];
    NSMutableString *resultString = [NSMutableString stringWithFormat:@"("];
    while ([result next]) {
        YTLocalMajorArea *tmpMajorArea = [[YTLocalMajorArea alloc]initWithDBResultSet:result];
        [resultString appendString:[NSString stringWithFormat:@"%@,",[tmpMajorArea identifier]]];
    }
    NSRange tmpRange;
    tmpRange.length = 1;
    tmpRange.location = resultString.length - 1;
    [resultString deleteCharactersInRange:tmpRange];
    [resultString appendString:@")"];
    
    return [resultString copy];
}

-(NSArray *)merchantsWithMerchantName:(NSString *)merchantName{
    NSMutableArray *merchantCount = [NSMutableArray array];
    FMDatabase *db = [YTDataManager defaultDataManager].database;
    FMResultSet *result = nil;
    if (_mall) {
        NSString *sql = [NSString stringWithFormat:@"select * from MerchantInstance where merchantInstanceName = ? and majorAreaId in %@",_majorAreaIds];
        result = [db executeQuery:sql, merchantName];
    }else{
        result = [db executeQuery:@"select * from MerchantInstance where merchantInstanceName = ?",merchantName];
    }
    
    while ([result next]) {
        YTLocalMerchantInstance *merchant = [[YTLocalMerchantInstance alloc]initWithDBResultSet:result];
        [merchantCount addObject:[merchant uniId]];
    }
    
    return [merchantCount copy];
}

-(void)setHistoricalRecordNames:(NSArray *)recordNames{
    FMDatabase *db = [YTDataManager defaultDataManager].database;
    NSMutableArray *tmpRecord = [NSMutableArray array];
    for (NSString *merchantName in recordNames) {
        FMResultSet *result = nil;
        
        result = [db executeQuery:@"select * from MerchantInstance where merchantInstanceName = ? ",merchantName];
        
        [result next];
        YTLocalMerchantInstance *tmpMerchantInstance = [[YTLocalMerchantInstance alloc]initWithDBResultSet:result];
        [tmpRecord addObject:tmpMerchantInstance];
        
    }
    if (_historyTableView != nil){
        CGRect frame = _historyTableView.frame;
        frame.size.height = tmpRecord.count * HISTORYTABLECELL_HEIGHT + 35;
        _historyTableView.frame = frame;
    }
    
    _recordObjects = [tmpRecord copy];
}

-(void)getHotSearch{
    AVQuery *query = [AVQuery queryWithClassName:MERCHANT_CLASS_NAME];
    [query whereKeyExists:@"uniId"];
    [query whereKey:@"uniId" notEqualTo:@""];
    if (_mall) {
        AVQuery *mallQuery = [AVQuery queryWithClassName:@"Mall"];
        if ([_mall isMemberOfClass:[YTLocalMall class]]){
            [mallQuery whereKey:MALL_CLASS_LOCALID equalTo:[_mall identifier]];
        }else{
            [mallQuery whereKey:MALL_CLASS_LOCALID equalTo:[_mall localDB]];
        }
        [query whereKey:@"mall" matchesQuery:mallQuery];
    }
    query.limit = 6;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            _popularMerchants = [NSArray arrayWithArray:objects];
            _notNetWordButton.hidden = true;
            NSArray *colors = @[[UIColor colorWithString:@"ecc3c4"],[UIColor colorWithString:@"81dd90"],[UIColor colorWithString:@"e7d76a"],[UIColor colorWithString:@"73d9e8"],[UIColor colorWithString:@"ee937a"],[UIColor colorWithString:@"b89ef2"]];
            for (int i = 0 ; i < objects.count; i++) {
                AVObject *object = objects[i];
                id<YTMerchant> merchant = [[YTCloudMerchant alloc]initWithAVObject:object];
                UIButton *hotButton = [[UIButton alloc]initWithFrame:CGRectMake(14.5  + i % 3 * 100 , 35 + i / 3 * 50, 90, 45)];
                [hotButton setTitle:[merchant shortName] forState:UIControlStateNormal];
                [hotButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [hotButton setBackgroundColor:colors[i]];
                [hotButton.layer setCornerRadius:5];
                [hotButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [hotButton addTarget:self action:@selector(jumpToMerchant:) forControlEvents:UIControlEventTouchUpInside];
                [hotButton.titleLabel setNumberOfLines:2];
                [hotButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
                hotButton.tag  = i;
                [_hotSearchView addSubview:hotButton];
            }
        }else{
            _notNetWordButton.hidden = false;
        }
        _isRefrest = false;
    }];
}

-(void)refreshHotSearch{
    if (!_isRefrest) {
        _isRefrest = true;
        [self getHotSearch];
    }
    
}

- (NSString *)getPinyin:(NSString *)str{
    CFMutableStringRef string  = CFStringCreateMutableCopy(NULL, 0, (__bridge CFStringRef)str);
    CFStringTransform(string, NULL, kCFStringTransformMandarinLatin, false);
    CFStringTransform(string, NULL, kCFStringTransformStripDiacritics, NO);
    return (__bridge NSString *)string;
}

-(void)dealloc{
    [_unIds removeAllObjects];
    [_results removeAllObjects];
    NSLog(@"searchDetails dealloc");
}

@end
