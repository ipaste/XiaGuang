//
//  YTMultipleMerchantView.m
//  虾逛
//
//  Created by YunTop on 14/12/2.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "YTMultipleMerchantView.h"
#define WIDTH 260
#define TABLECELL_HEIGHT 40
@implementation YTMultipleMerchantView{
    NSMutableArray *_merchants;
    CGRect _screenBounds;
    UIView *_backgroundView;
    UITableView *_tableView;
    UILabel *_textLabel;
    id<YTMultipleMerchantDelegate> _delegate;
}
-(instancetype)initWithUniIds:(NSArray *)uniIds delegate:(id<YTMultipleMerchantDelegate>)delegate{
    _screenBounds = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH, TABLECELL_HEIGHT * uniIds.count + 20)];
    if (self) {
        _merchants = [NSMutableArray array];
        _delegate = delegate;
        
        _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, TABLECELL_HEIGHT * uniIds.count + 20 ) ];
        [self addSubview:_backgroundView];
        
        _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, WIDTH, 20)];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.text = [NSString stringWithFormat:@"搜索结果中有%ld个商家",uniIds.count];
        _textLabel.textAlignment = 1;
        _textLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_textLabel];
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_textLabel.frame), WIDTH, uniIds.count * TABLECELL_HEIGHT)];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            FMDatabase *db = [YTDataManager defaultDataManager].database;
            for (NSString *tmpUniId in uniIds) {
                FMResultSet *result = [db executeQuery:@"select * from MerchantInstance where uniId = ?",tmpUniId];
                [result next];
                YTLocalMerchantInstance *tmpMerchantInstance = [[YTLocalMerchantInstance alloc]initWithDBResultSet:result];
                [_merchants addObject:tmpMerchantInstance];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        });
    }
    return self;
}

-(void)layoutSubviews{
    _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    _backgroundView.layer.cornerRadius = 10.0;
    _backgroundView.layer.masksToBounds = YES;
    
    
    self.center = CGPointMake(CGRectGetWidth(_screenBounds) / 2, CGRectGetHeight(_screenBounds) / 2);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _merchants.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    id<YTMerchantLocation> tmpMerchantInstance = _merchants[indexPath.row];
    NSString *merchantName = [tmpMerchantInstance merchantLocationName];
    
    CGSize textSize = [merchantName boundingRectWithSize:CGSizeMake(100, 40) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, textSize.width + 50, 40)];
    backgroundView.center = CGPointMake(WIDTH / 2, backgroundView.center.y);
    [cell addSubview:backgroundView];
    
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, textSize.width, 40)];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.text = merchantName;
    titleLable.font = [UIFont systemFontOfSize:16];
    [backgroundView addSubview:titleLable];
    
    UILabel *subLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLable.frame), CGRectGetMinY(titleLable.frame), 50, 40)];
    subLabel.textColor = [UIColor whiteColor];
    subLabel.font = [UIFont systemFontOfSize:14];
    subLabel.text = [NSString stringWithFormat:@"(%@)",[[tmpMerchantInstance floor] floorName]];
    [backgroundView addSubview:subLabel];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_delegate selectToMerchantInstance:_merchants[indexPath.row]];
    [self hide];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TABLECELL_HEIGHT;
}

-(void)showInView:(UIView *)superView{
    _isShow = YES;
    [superView addSubview:self];
}

-(void)hide{
    _isShow = NO;
    [self removeFromSuperview];
}

@end
