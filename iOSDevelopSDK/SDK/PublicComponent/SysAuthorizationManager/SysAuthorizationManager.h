//
//  MXSysAuthorizationManager.h
//  jupiter
//
//  Created by Hayder on 2017/2/4.
//  Copyright © 2017年 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

typedef enum : NSUInteger {
    KAVMediaVideo = 0,      //相机
    KALAssetsLibary,        //相册
    KCLLocation,            //地理定位
    KAVMediaAudio,          //音频
    KABAddressBook,         //通讯录
} SysAuthorizationType;

@interface SysAuthorizationManager : NSObject


+(instancetype)sharenInsatnce;

/*
 * 设置权限
 * type:类型
 * completion:Blook,error:禁止权限则有值
 */
-(void)requestAuthorization:(SysAuthorizationType)type completion:(void(^)(NSError *error))completion;

/*
 * 推送权限
 */
-(void)setLocPushRequestTarget:(id<UNUserNotificationCenterDelegate>)target Completion:(void(^)(BOOL granted,NSError *error))completion;

@end
