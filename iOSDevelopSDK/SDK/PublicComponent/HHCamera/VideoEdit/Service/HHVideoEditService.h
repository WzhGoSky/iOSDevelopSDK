//
//  HHVideoEditService.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/27.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface HHVideoEditService : NSObject

/**
 根据给定时段裁剪视频

 @param videoAsset 视频资源文件
 @param startTime 开始时间,单位秒
 @param endTime 结束时间，单位秒
 @param completion 完成回调
 */
+ (void)clipVideoWithVideoAssest:(AVAsset *)videoAsset startTime:(CGFloat)startTime endTime:(CGFloat)endTime completion:(void (^)(NSURL *outputPath, NSError *error))completion;

/**
 添加水印

 @param videoAssest 视频资源文件
 @param waterMask 水印图片
 @param completion 完成回调
 */
+ (void)addWaterMaskToVideoAssest:(AVAsset *)videoAssest waterMaskImage:(UIImage *)waterMask completion:(void (^)(NSURL *outputPath, NSError *error))completion;

@end
