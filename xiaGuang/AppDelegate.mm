//
//  AppDelegate.m
//  xiaGuang
//
//  Created by YunTop on 14-10-24.
//  Copyright (c) 2014年 YunTop. All rights reserved.
//

#import "AppDelegate.h"

#import <AVOSCloud/AVOSCloud.h>
#import <AdSupport/AdSupport.h>
#import <AFNetworking.h>
#import "YTDataManager.h"
#import "YTNavigationController.h"
#import "YTGuideViewController.h"

@interface AppDelegate ()<YTGuideDelegate> {
    double _timeInToBackground;
    YTNavigationController *_navigation;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after application launch.
    
    double startTime = [[NSDate date] timeIntervalSinceReferenceDate];
    [AVOSCloud setApplicationId:@"p8eq0otfz420q56dsn8s1yp8dp82vopaikc05q5h349nd87w" clientKey:@"kzx1ajhbxkno0v564rcremcz18ub0xh2upbjabbg5lruwkqg"];
    [AVAnalytics setChannel:@""];
    
    self.window = [[UIWindow alloc]init];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor blackColor];
    
    _timeInToBackground = 0;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id first = [userDefaults objectForKey:@"first"];
    if (!first) {
        [userDefaults setObject:@YES forKey:@"first"];
        YTGuideViewController *guideVC = [[YTGuideViewController alloc]init];
        guideVC.delegate = self;
        self.window.rootViewController = guideVC;
    }else{
        self.window.rootViewController = [[YTNavigationController alloc]initWithCreateHomeViewController];
    }
    
    double timeDifference = [[NSDate date]timeIntervalSinceReferenceDate] - startTime;
    
    [self.window makeKeyAndVisible];
    if (timeDifference < 0.8) {
        [NSThread sleepForTimeInterval:0.3];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interXruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _timeInToBackground = [[NSDate date] timeIntervalSinceReferenceDate];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    double now = [[NSDate date] timeIntervalSinceReferenceDate];
    if (now - _timeInToBackground >= 10 * 60) { // 30 minutes wait
        id currentViewController = [[self.window subviews][0] nextResponder];
        if ([currentViewController isMemberOfClass:[YTNavigationController class]]) {
            [(UINavigationController *)currentViewController popToRootViewControllerAnimated:false];
        }else{
            [(UIViewController *)currentViewController dismissViewControllerAnimated:false completion:nil];
        }
    }
    [NSThread sleepForTimeInterval:0.5];
    
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[YTDataManager defaultDataManager]closeAllDatebase];
}


//- (NSString *)identifierForAdvertising
//{
//    if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled])
//    {
//        NSUUID *IDFA = [[ASIdentifierManager sharedManager] advertisingIdentifier];
//        
//        return [IDFA UUIDString];
//    }
//    
//    return nil;
//}
//
//-(void)youmiProcedure{
//    
//    NSString *idfa = [self identifierForAdvertising];
//    
//    if(idfa == nil){
//        return;
//    }
//    
//    AVQuery *query = [AVQuery queryWithClassName:@"YoumiRecord"];
//    [query whereKey:@"ifa" equalTo:idfa];
//    [query whereKey:@"sent" equalTo:@NO];
//    [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
//        if(!error){
//            NSString *url = object[@"callback"];
//            if(url != nil && ![url isEqualToString:@""]){
//                NSString *decoded = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                if(decoded != nil && ![decoded isEqualToString:@""]){
//                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//                    [manager GET:decoded parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                        object[@"sent"] = @YES;
//                        [object saveEventually];
//                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                        object[@"failed"] = @YES;
//                        [object saveEventually];
//                    }];
//                }
//                else{
//                    object[@"failed"] = @YES;
//                    [object saveEventually];
//                }
//            }
//            
//        }
//    }];
//    
//}

-(void)dismissGuideViewController{
    self.window.rootViewController = [[YTNavigationController alloc]initWithCreateHomeViewController];
    [self.window makeKeyAndVisible];
}

-(void)initialization{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSString *currentPath = [path stringByAppendingPathComponent:@"current"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:currentPath]) {
        [fileManager removeItemAtPath:currentPath error:nil];
    }
}

    
@end
