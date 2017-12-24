//
//  AppDelegate.m
//  JPUSH
//
//  Created by 柳麟喆 on 2017/3/19.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "AppDelegate.h"
#import "JPUSHService.h"
#import "ViewController.h"
#import "RecordViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Required
    self.window =[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor=[UIColor whiteColor];
    

    UITabBarController *bar=[[UITabBarController alloc]init];
    
    
    ViewController *v1=[[ViewController alloc]init];
    v1.tabBarItem.title=@"发送通知";
    v1.tabBarItem.image=[UIImage imageNamed:@"game"];
    
    RecordViewController *v2=[[RecordViewController alloc]init];
    v2.tabBarItem.title=@"历史记录";
    v2.tabBarItem.image=[UIImage imageNamed:@"game2"];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:v1];
    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:v2];
    
    [bar addChildViewController:navController];
    [bar addChildViewController:navController1];
    
    
    self.window.rootViewController = bar;
    [self.window makeKeyAndVisible];

//    JPUSHService
    if ([[UIDevice currentDevice].systemVersion floatValue] >=
        8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |UIUserNotificationTypeSound |UIUserNotificationTypeAlert)categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert)categories:nil];
    }
    
    [JPUSHService setupWithOption:launchOptions appKey:@"4a4c3862607556314143f93a" channel:@"" apsForProduction:NO];
//    本地通知
    // 创建分类，注意使用可变子类
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc]init];
    // 设置标识符，注意与发送通知设置的category标识符一致~！
    category.identifier = @"category";
    // 设置按钮，注意使用可变子类UIMutableUserNotificationAction
    // 设置前台按钮，点击后能使程序回到前台的叫做前台按钮
    UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc]init];
    action1.identifier = @"qiantai";
    action1.activationMode = UIUserNotificationActivationModeForeground;
    // 设置按钮的标题，即按钮显示的文字
    action1.title = @"前台";
    
    // 设置后台按钮，点击后程序还在后台执行，如QQ的消息
    UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc]init];
    action2.identifier = @"houtai";
    action2.activationMode = UIUserNotificationActivationModeBackground;
    // 设置按钮的标题，即按钮显示的文字
    action2.title = @"后台";
    // 给分类设置按钮
    [category setActions:@[action1,action2] forContext:UIUserNotificationActionContextDefault];
    
    // 注册，请求授权的时候将分类设置给授权，注意是 NSSet 集合
    NSSet *categorySet = [NSSet setWithObject:category];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) { // iOS8
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:categorySet];
        [application registerUserNotificationSettings:setting];
    }
    
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        // 这里添加处理代码

    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    //在applicationWillEnterForeground方法（App即将进入前台）中将小红点清除
    NSLog(@"清除小红点");
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma JPUSH方法
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //这个方法是设置别名和tag 可省
//     [JPUSHService setTags:nil alias:@"WzxJiang" fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
//            NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, iTags , iAlias);
//       }];
    // Required
    [JPUSHService registerDeviceToken:deviceToken];
}
//App在后台时收到推送时的处理
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    //iOS 7及之后才能用，现在没人适配iOS6了吧...
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
//处理接收推送错误的情况
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
#pragma mark-localNotification
//本地推送通知
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // 这里添加处理代码
    NSLog(@"点击弹出框");
    
    //NSLog(@"小点点个数：%d",(int)[UIApplication sharedApplication].applicationIconBadgeNumber);
    //NSLog(@"%@", notification.userInfo);
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)(void))completionHandler{
    // 我们可以在这里获取标识符，根据标识符进行判断是前台按钮还是后台按钮还是神马按钮，进行相关逻辑处理（如回复消息）
    NSLog(@"identifier : %@",identifier);
    // 一旦接受必须调用的方法（告诉系统什么时候结束，系统自己对内部进行资源调配）
    completionHandler();
}
@end

