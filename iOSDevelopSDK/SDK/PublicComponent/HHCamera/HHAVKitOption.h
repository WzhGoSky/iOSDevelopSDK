//
//  HHAVKitOption.h
//  HHCamera
//
//  Created by Hayder on 2018/10/4.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHCameraHelper.h"

@interface HHAVKitOption : NSObject

//类型 默认是拍照模式
@property (nonatomic, assign, readonly) SessionType type;

#pragma mark ---------------------照相模式-----------------------------------------
//最大照片数
@property (nonatomic, assign, readonly) NSInteger maxPhotoCount;
//拍摄的像素比
@property (nonatomic, assign, readonly) SessionPreset preset;

#pragma mark ---------------------摄像模式-----------------------------------------
/**录像时长*/
@property (nonatomic, assign, readonly) NSInteger recordMaxTime;
//画质，一般选择中等
@property (nonatomic, assign, readonly) NSInteger qualityLevel;

/**显示编辑的视频时间 默认：60s*/
@property (nonatomic, assign) NSInteger showEditButtonTime;

//默认的选项
+ (instancetype)defaultOption;

//相机的拍摄照片的清晰度 和 最大照片数
- (instancetype)initOnPhotoModeWithSessionPreset:(SessionPreset)preset;
//相机的拍摄照片的清晰度 和 最大照片数
- (instancetype)initOnPhotoModeWithSessionPreset:(SessionPreset)preset MaxPhotoCount:(NSInteger)count;

//摄像机拍摄的清晰度 和 最长时间
- (instancetype)initOnVideoModeWithQualityLevel:(QualityLevel) qualityLevel MaxSecond:(NSInteger)maxSecond;
@end
