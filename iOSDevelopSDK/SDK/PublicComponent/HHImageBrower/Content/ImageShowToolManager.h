//
//  ImageShowToolManager.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/23.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageShowConfig.h"

@interface ImageShowToolManager : NSObject

/**
 下载图片
 */
+(void)ImageShowDownLoadImgWithUrl:(NSString *)imgUrl img:(UIImage *)img originalImgUrl:(NSString *)originalUrl isOriginal:(BOOL)isOriginal savedFinfish:(SEL)savedFinfish target:(id)completionTarget;

/**
 下载视频
 */
+(void)ImageShowDownLoadVideoWithUrl:(NSString *)videoUrl HUDInView:(UIView *)view savedFinfish:(SEL)savedFinfish target:(id)completionTarget;

/**
 编辑图片
 */
+(void)ImageShowEidtImage:(UIImage *)img savedFinfish:(SEL)savedFinfish target:(id)completionTarget;

/**
 查看原图
 */
+(void)ImageShowOriginalImg:(NSString *)originalUrl complete:(void(^)(UIImage *originalImg))complete porgress:(void(^)(NSString *stateTitle))progress;

/**
 * 获取当前显示的控制器
 */
+ (UIViewController *)getCurrentController;

+ (UIViewController *)getPresentController;

@end
