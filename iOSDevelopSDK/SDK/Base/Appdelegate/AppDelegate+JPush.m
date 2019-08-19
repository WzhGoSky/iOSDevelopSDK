//
//  AppDelegate+JPush.m
//  JYQX
//
//  Created by Hayder on 2018/9/17.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "AppDelegate+JPush.h"
#import "globalDefine.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@implementation AppDelegate (JPush)

/**
 配置极光推送
 */
- (void)configJPushWithLaunchingOptions:(NSDictionary *)launchOptions;
{
    BOOL apsForProduction = NO;
#ifdef DEBUG
    apsForProduction = NO;
#else
    apsForProduction = YES;
#endif
    // 3.0.0及以后版本注册可以这样写，也可以继续用旧的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    [JPUSHService setupWithOption:launchOptions appKey:@"fcceee0eb2adf7dee9c20059" channel:@"Publish channel" apsForProduction:apsForProduction];
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            [JPUSHService setAlias:@"alais" completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                if (iResCode == 0) {
                    
                }
            } seq:1];
        }
    }];
}

- (void)logOutPushWithComolete:(void (^)(void))block
{
    [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        if (block) {
            block();
        }
    } seq:2];
}

-(void)applicationDidFinishLaunching:(UIApplication *)application{
    //重置角标
    [application setApplicationIconBadgeNumber:0];
    [JPUSHService resetBadge];
}

-(void)applicationWillEnterForeground:(UIApplication *)application{
    //重置角标
    [application setApplicationIconBadgeNumber:0];
    [JPUSHService resetBadge];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
{
    [JPUSHService registerDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [JPUSHService handleRemoteNotification:userInfo];

    //ios8~9
    if (!kisiOS10) {
        [self handleNotification:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger options))completionHandler
API_AVAILABLE(ios(10.0)){
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    
    //此方法当app在前台，会自动发送localNotification
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        //程序在前台
        [self handleNotification:userInfo];
        completionHandler(UNNotificationPresentationOptionSound); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    }
    else{
        //程序在后台
        completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    }

}

-(void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)){
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    [self handleNotification:userInfo];
    completionHandler();  // 系统要求执行这个方法
}

//推送消息处理
- (void)handleNotification:(NSDictionary *)userInfo{
    
    
}

@end
