//
//  YTCategory.m
//  HighGuang
//
//  Created by Ke ZhuoPeng on 14-9-12.
//  Copyright (c) 2014年 Yuan Tao. All rights reserved.
//

#import "YTCategory.h"
#import "UIColor+ExtensionColor_UIImage+ExtensionImage.h"
@implementation YTCategory
+(NSArray*)commonlyCategorysWithAddMore:(BOOL)isMore{
    YTCategory *food = [[YTCategory alloc]init];
    food.text = @"美食";
    food.subText = @[@"全部",@"中餐",@"西餐",@"日式",@"韩式",@"快餐",@"其它"];
    food.image = [UIImage imageNamed:@"nav_ico_1"];
    food.smallImage = [UIImage imageNamed:@"nav_ico_1small"];
    food.tintColor = [UIColor colorWithString:@"ff992b"];
    food.titleColor = food.tintColor;
    
    
    YTCategory *clothing = [[YTCategory alloc]init];
    clothing.text = @"服装";
    clothing.subText = @[@"全部",@"女装",@"男装",@"童装",@"内衣",@"运动"];
    clothing.image = [UIImage imageNamed:@"nav_ico_2"];
    clothing.smallImage = [UIImage imageNamed:@"nav_ico_2small"];
    clothing.tintColor = [UIColor colorWithString:@"0bd48b"];
    clothing.titleColor = [UIColor colorWithString:@"00c57d"];
    
    YTCategory *entertainment = [[YTCategory alloc]init];
    entertainment.text = @"娱乐";
    entertainment.subText = @[@"全部",@"电影",@"KTV",@"酒吧",@"其他"];
    entertainment.image = [UIImage imageNamed:@"nav_ico_3"];
    entertainment.smallImage = [UIImage imageNamed:@"nav_ico_3small"];
    entertainment.tintColor = [UIColor colorWithString:@"ff694c"];
    entertainment.titleColor = [UIColor colorWithString:@"f65738"];
    
    YTCategory *dessert = [[YTCategory alloc]init];
    dessert.text = @"甜品";
    dessert.subText = @[@"全部",@"饮品",@"甜点",@"面包",@"雪糕"];
    dessert.image = [UIImage imageNamed:@"nav_ico_4"];
    dessert.smallImage = [UIImage imageNamed:@"nav_ico_4small"];
    dessert.tintColor = [UIColor colorWithString:@"26cdeb"];
    dessert.titleColor = [UIColor colorWithString:@"17c1e0"];
    
    YTCategory *goods = [[YTCategory alloc]init];
    goods.text = @"精品";
    goods.subText = @[@"全部",@"礼品",@"钟表",@"首饰",@"眼镜",@"其他"];
    goods.image = [UIImage imageNamed:@"nav_ico_6"];
    goods.smallImage = [UIImage imageNamed:@"nav_ico_6small"];
    goods.tintColor = [UIColor colorWithString:@"51afff"];
    goods.titleColor = [UIColor colorWithString:@"40aaf7"];
    
    YTCategory *beauty = [[YTCategory alloc]init];
    beauty.text = @"丽人";
    beauty.subText =  @[@"全部",@"彩妆",@"美体",@"美容",@"美甲",@"美发"];
    beauty.image = [UIImage imageNamed:@"nav_ico_5"];
    beauty.smallImage = [UIImage imageNamed:@"nav_ico_5small"];
    beauty.tintColor = [UIColor colorWithString:@"f24682"];
    beauty.titleColor = [UIColor colorWithString:@"f9568f"];
    
    
    YTCategory *children = [[YTCategory alloc]init];
    children.text = @"亲子";
    children.subText =  @[@"全部",@"玩具",@"孕婴",@"童装",@"童鞋",@"其他"];
    children.image = [UIImage imageNamed:@"nav_ico_7"];
    children.smallImage = [UIImage imageNamed:@"nav_ico_7small"];
    children.tintColor = [UIColor colorWithString:@"10c7d3"];
    children.titleColor = [UIColor colorWithString:@"10c7d3"];
    
    

    NSArray *categorys = @[food,clothing,entertainment,dessert,goods,beauty,children];
    if (isMore) {
        NSMutableArray *mutableCategorys = [NSMutableArray arrayWithArray:categorys];
        [mutableCategorys addObject:[self moreCategory]];
        return mutableCategorys;
    }
    return categorys;
}

+(YTCategory *)moreCategory{
    YTCategory *more = [[YTCategory alloc]init];
    more.text = @"全部分类";
    more.subText =  @[@"数码",@"鞋包",@"生活",@"运动"];
    more.image = [UIImage imageNamed:@"nav_ico_more_1"];
    more.smallImage = [UIImage imageNamed:@"nav_ico_more_1small"];
    return more;
}

+(NSArray *)allCategorys{
    NSMutableArray *allCategorys = [NSMutableArray arrayWithArray:[self commonlyCategorysWithAddMore:NO]];
    
    YTCategory *digital = [[YTCategory alloc]init];
    digital.text = @"数码";
    digital.subText =  @[@"全部",@"手机",@"电脑",@"影音",@"家电",@"其他"];
    digital.image = [UIImage imageNamed:@"nav_ico_14"];
    digital.smallImage = [UIImage imageNamed:@"nav_ico_14small"];
    digital.tintColor = [UIColor colorWithString:@"4a8bc7"];
    digital.titleColor = [UIColor colorWithString:@"4b80c8"];
    [allCategorys addObject:digital];
    
    YTCategory *shoeAndBag = [[YTCategory alloc]init];
    shoeAndBag.text = @"鞋包";
    shoeAndBag.subText =  @[@"全部",@"女鞋",@"男鞋",@"童鞋",@"包包",@"旅行箱"];
    shoeAndBag.image = [UIImage imageNamed:@"nav_ico_15"];
    shoeAndBag.smallImage = [UIImage imageNamed:@"nav_ico_15small"];
    shoeAndBag.tintColor = [UIColor colorWithString:@"e94956"];
    shoeAndBag.titleColor = [UIColor colorWithString:@"ff4665"];
    [allCategorys addObject:shoeAndBag];
    
    
    YTCategory *life = [[YTCategory alloc]init];
    life.text = @"生活";
    life.subText =  @[@"全部",@"家具",@"摄影",@"花草",@"医药",@"百货"];
    life.image = [UIImage imageNamed:@"nav_ico_16"];
    life.smallImage = [UIImage imageNamed:@"nav_ico_16small"];
    life.tintColor = [UIColor colorWithString:@"90bc0c"];
    life.titleColor = [UIColor colorWithString:@"779b0d"];
    [allCategorys addObject:life];
    
    
    YTCategory *movement = [[YTCategory alloc]init];
    movement.text = @"运动";
    movement.subText =  @[@"全部",@"健身",@"运动用品"];
    movement.image = [UIImage imageNamed:@"nav_ico_17"];
    movement.smallImage = [UIImage imageNamed:@"nav_ico_17small"];
    movement.tintColor = [UIColor colorWithString:@"fe6941"];
    movement.titleColor = [UIColor colorWithString:@"fe6941"];
    [allCategorys addObject:movement];

    return [allCategorys copy];
}

+(CGFloat)calculateHeightForCategory:(YTCategory *)category{
    CGFloat height = 20;
    
    height += 16;
    
    height += 2;
    
    height += 0.5;
    
    height += 10;
    
    height += 10;
    
    height += category.subText.count / 3 * 30;

    height += category.subText.count % 3 > 0 ? 30 : 0;

    return height;
}
@end
