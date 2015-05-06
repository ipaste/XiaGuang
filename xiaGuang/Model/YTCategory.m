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
    food.subText = @[@"全部",@"中餐",@"西餐",@"日式",@"韩式",@"快餐"];
    food.image = [UIImage imageNamed:@"nav_ico_1"];
    food.smallImage = [UIImage imageNamed:@"nav_ico_1small"];
    food.tintColor = [UIColor colorWithString:@"b2b2b2"];
    food.titleColor = [UIColor colorWithString:@"666666"];
    
    
    YTCategory *clothing = [[YTCategory alloc]init];
    clothing.text = @"服饰";
    clothing.subText = @[@"全部",@"女装",@"男装",@"童装",@"内衣",@"运动"];
    clothing.image = [UIImage imageNamed:@"nav_ico_2"];
    clothing.smallImage = [UIImage imageNamed:@"nav_ico_2small"];
    clothing.tintColor = [UIColor colorWithString:@"b2b2b2"];
    clothing.titleColor = [UIColor colorWithString:@"666666"];
    
    YTCategory *entertainment = [[YTCategory alloc]init];
    entertainment.text = @"娱乐";
    entertainment.subText = @[@"全部",@"电影",@"KTV",@"酒吧"];
    entertainment.image = [UIImage imageNamed:@"nav_ico_3"];
    entertainment.smallImage = [UIImage imageNamed:@"nav_ico_3small"];
    entertainment.tintColor = [UIColor colorWithString:@"b2b2b2"];
    entertainment.titleColor = [UIColor colorWithString:@"666666"];
    
    YTCategory *beauty = [[YTCategory alloc]init];
    beauty.text = @"丽人";
    beauty.subText =  @[@"全部",@"彩妆",@"美体",@"美容",@"美甲",@"美发"];
    beauty.image = [UIImage imageNamed:@"nav_ico_4"];
    beauty.smallImage = [UIImage imageNamed:@"nav_ico_5small"];
    beauty.tintColor = [UIColor colorWithString:@"b2b2b2"];
    beauty.titleColor = [UIColor colorWithString:@"666666"];
    
//    YTCategory *dessert = [[YTCategory alloc]init];
//    dessert.text = @"甜品";
//    dessert.subText = @[@"全部",@"饮品",@"甜点",@"面包",@"雪糕"];
//    dessert.image = [UIImage imageNamed:@"nav_ico_4"];
//    dessert.smallImage = [UIImage imageNamed:@"nav_ico_4small"];
//    dessert.tintColor = [UIColor colorWithString:@"b2b2b2"];
//    dessert.titleColor = [UIColor colorWithString:@"666666"];
    
    YTCategory *goods = [[YTCategory alloc]init];
    goods.text = @"配饰";
    goods.subText = @[@"全部",@"礼品",@"钟表",@"首饰",@"眼镜"];
    goods.image = [UIImage imageNamed:@"nav_ico_5"];
    goods.smallImage = [UIImage imageNamed:@"nav_ico_5small"];
    goods.tintColor = [UIColor colorWithString:@"b2b2b2"];
    goods.titleColor = [UIColor colorWithString:@"666666"];
    
    YTCategory *home = [[YTCategory alloc]init];
    home.text = @"居家";
    home.subText = @[@"全部",@"",@"",@"",@""];
    home.image = [UIImage imageNamed:@"nav_ico_6"];
    home.smallImage = [UIImage imageNamed:@"nav_ico_6small"];
    home.tintColor = [UIColor colorWithString:@"b2b2b2"];
    home.titleColor = [UIColor colorWithString:@"666666"];
    
    YTCategory *service = [[YTCategory alloc]init];
    service.text = @"服务";
    service.subText = @[@"全部",@"",@"",@"",@"",];
    service.image = [UIImage imageNamed:@"nav_ico_7"];
    service.smallImage = [UIImage imageNamed:@"nav_ico_7small"];
    service.tintColor = [UIColor colorWithString:@"b2b2b2"];
    service.titleColor = [UIColor colorWithString:@"666666"];
    
//    YTCategory *children = [[YTCategory alloc]init];
//    children.text = @"亲子";
//    children.subText =  @[@"全部",@"玩具",@"孕婴",@"童装",@"童鞋"];
//    children.image = [UIImage imageNamed:@"nav_ico_7"];
//    children.smallImage = [UIImage imageNamed:@"nav_ico_7small"];
//    children.tintColor = [UIColor colorWithString:@"b2b2b2"];
//    children.titleColor = [UIColor colorWithString:@"666666"];
    
    

    NSArray *categorys = @[food,clothing,entertainment,beauty,goods,home,service];
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
    digital.subText =  @[@"全部",@"手机",@"电脑",@"影音",@"家电"];
    digital.image = [UIImage imageNamed:@"nav_ico_14"];
    digital.smallImage = [UIImage imageNamed:@"nav_ico_14small"];
    digital.tintColor = [UIColor colorWithString:@"b2b2b2"];
    digital.titleColor = [UIColor colorWithString:@"666666"];
    [allCategorys addObject:digital];
    
    YTCategory *shoeAndBag = [[YTCategory alloc]init];
    shoeAndBag.text = @"鞋包";
    shoeAndBag.subText =  @[@"全部",@"女鞋",@"男鞋",@"童鞋",@"包包",@"旅行箱"];
    shoeAndBag.image = [UIImage imageNamed:@"nav_ico_15"];
    shoeAndBag.smallImage = [UIImage imageNamed:@"nav_ico_15small"];
    shoeAndBag.tintColor = [UIColor colorWithString:@"b2b2b2"];
    shoeAndBag.titleColor = [UIColor colorWithString:@"666666"];
    [allCategorys addObject:shoeAndBag];
    
    
    YTCategory *life = [[YTCategory alloc]init];
    life.text = @"生活";
    life.subText =  @[@"全部",@"家具",@"摄影",@"花草",@"医药",@"百货"];
    life.image = [UIImage imageNamed:@"nav_ico_16"];
    life.smallImage = [UIImage imageNamed:@"nav_ico_16small"];
    life.tintColor = [UIColor colorWithString:@"b2b2b2"];
    life.titleColor = [UIColor colorWithString:@"666666"];
    [allCategorys addObject:life];
    
    
    YTCategory *movement = [[YTCategory alloc]init];
    movement.text = @"运动";
    movement.subText =  @[@"全部",@"健身",@"运动用品"];
    movement.image = [UIImage imageNamed:@"nav_ico_17"];
    movement.smallImage = [UIImage imageNamed:@"nav_ico_17small"];
    movement.tintColor = [UIColor colorWithString:@"b2b2b2"];
    movement.titleColor = [UIColor colorWithString:@"666666"];
    [allCategorys addObject:movement];

    return [allCategorys copy];
}

+ (NSArray *)newAllCategorys{
    YTCategory *food = [[YTCategory alloc]init];
    food.text = @"美食";
    food.image = [UIImage imageNamed:@"nav_ico_1"];
    food.smallImage = [UIImage imageNamed:@"nav_ico_1small"];
    food.tintColor = [UIColor colorWithString:@"b2b2b2"];
    food.titleColor = [UIColor colorWithString:@"666666"];
    
    YTCategory *clothing = [[YTCategory alloc]init];
    clothing.text = @"服饰";
    clothing.image = [UIImage imageNamed:@"nav_ico_2"];
    clothing.smallImage = [UIImage imageNamed:@"nav_ico_2small"];
    clothing.tintColor = [UIColor colorWithString:@"b2b2b2"];
    clothing.titleColor = [UIColor colorWithString:@"666666"];
    
    YTCategory *entertainment = [[YTCategory alloc]init];
    entertainment.text = @"娱乐";
    entertainment.image = [UIImage imageNamed:@"nav_ico_3"];
    entertainment.smallImage = [UIImage imageNamed:@"nav_ico_3small"];
    entertainment.tintColor = [UIColor colorWithString:@"b2b2b2"];
    entertainment.titleColor = [UIColor colorWithString:@"666666"];
    
    YTCategory *beauty = [[YTCategory alloc]init];
    beauty.text = @"丽人";
    beauty.image = [UIImage imageNamed:@"nav_ico_4"];
    beauty.smallImage = [UIImage imageNamed:@"nav_ico_5small"];
    beauty.tintColor = [UIColor colorWithString:@"b2b2b2"];
    beauty.titleColor = [UIColor colorWithString:@"666666"];
    
    YTCategory *goods = [[YTCategory alloc]init];
    goods.text = @"配饰";
    goods.image = [UIImage imageNamed:@"nav_ico_5"];
    goods.smallImage = [UIImage imageNamed:@"nav_ico_5small"];
    goods.tintColor = [UIColor colorWithString:@"b2b2b2"];
    goods.titleColor = [UIColor colorWithString:@"666666"];
    
    YTCategory *home = [[YTCategory alloc]init];
    home.text = @"居家";
    home.image = [UIImage imageNamed:@"nav_ico_6"];
    home.smallImage = [UIImage imageNamed:@"nav_ico_6small"];
    home.tintColor = [UIColor colorWithString:@"b2b2b2"];
    home.titleColor = [UIColor colorWithString:@"666666"];
    
    YTCategory *service = [[YTCategory alloc]init];
    service.text = @"服务";
    service.image = [UIImage imageNamed:@"nav_ico_7"];
    service.smallImage = [UIImage imageNamed:@"nav_ico_7small"];
    service.tintColor = [UIColor colorWithString:@"b2b2b2"];
    service.titleColor = [UIColor colorWithString:@"666666"];
    
    YTCategory *other = [[YTCategory alloc]init];
    other.text = @"其它";
    other.image = [UIImage imageNamed:@"nav_ico_more_1"];
    other.smallImage = [UIImage imageNamed:@"nav_ico_more_1small"];
    other.tintColor = [UIColor colorWithString:@"b2b2b2"];
    other.titleColor = [UIColor colorWithString:@"666666"];
    return @[food,clothing,entertainment,beauty,goods,home,service,other];
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
