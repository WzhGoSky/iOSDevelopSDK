//
//  AppDelegate+JPush.h
//  JYQX
//
//  Created by Hayder on 2018/9/17.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "AppDelegate.h"
#import <JPush/JPUSHService.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate (JPush) <JPUSHRegisterDelegate>

#pragma mark ---------------------JPush-----------------------------------------

/**配置极光推送*/
- (void)configJPushWithLaunchingOptions:(NSDictionary *)launchOptions;
    
/**注销推送*/
- (void)logOutPushWithComolete:(void (^)(void))block;

@end
