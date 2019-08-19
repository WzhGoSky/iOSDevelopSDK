//
//  PickerConfigManager.h
//  TZImagePickerController
//
//  Created by Hayder on 2018/9/7.
//  Copyright © 2018年 Hayder. All rights reserved.
//  根据枚举值来配置alert选项

#import <Foundation/Foundation.h>
#import "PickerConfig.h"
#import <UIKit/UIKit.h>
#import "HHCameraHelper.h"

@interface PickerManagerConfig : NSObject

/**
 是否可以选择视频
 */
@property (nonatomic, assign) BOOL allowPickingVideo;
/**
 是否可以选择图片
 */
@property (nonatomic, assign) BOOL allowPickingImage;
/**
 相册是否可以编辑
 */
@property (nonatomic, assign) BOOL albumEdit;
/**
 拍照后是否可以编辑
 */
@property (nonatomic, assign) BOOL takePhotoEdit;
/**
 最大选择个数
 */
@property (nonatomic, assign) NSInteger maxImgCount;
/**
 相册显示列数，默认4
 */
@property (nonatomic, assign) NSInteger columnNumber;
/**
 是否可以选择原图
 */
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;

/**
 是否显示原图按钮
 */
@property (nonatomic, assign) BOOL needOriginal;

/**
 相册内 视频最大长度
 */
@property (nonatomic, assign) NSInteger videoMaximumDuration;

/**
 最大拍摄时长
 */
@property (nonatomic, assign) NSInteger recordMaxTime;

/**
 在内部显示拍视频按
 */
@property (nonatomic, assign) BOOL showTakeVideo;

/**
 在内部显示拍照按钮
 */
@property (nonatomic, assign) BOOL showTakePhoto;
/**
 gif图片
 */
@property (nonatomic, assign) BOOL allowPickingGif;
/**
 是否可以多选视频
 */
@property (nonatomic, assign) BOOL allowPickingMuitlpleVideo;
/**
 照片排列按修改时间升序
 */
@property (nonatomic, assign) BOOL sortAscending;
/**
 是否使用圆形裁剪
 */
@property (nonatomic, assign) BOOL needCircleCrop;
/**
 允许裁剪,默认为YES，showSelectBtn为NO才生效
 */
@property (nonatomic, assign) BOOL allowCrop;
/**
 是否显示图片序列号
 */
@property (nonatomic, assign) BOOL showSelectedIndex;

/**
 显示的选择途径：相册，拍照 ，拍小视频
 */
@property (nonatomic, assign) PickerMangerType type;

@property (nonatomic, strong, readonly) NSMutableArray *alertActions;
/**
 相机拍照最大选择张数
 */
@property (nonatomic, assign) NSInteger maxPhotoCount;
/**
 相机拍摄的像素比
 */
@property (nonatomic, assign) SessionPreset preset;
/**
 短视频画质，一般选择中等
 */
@property (nonatomic, assign) QualityLevel qualityLevel;


#pragma ---------alertactions
@property (nonatomic, strong) void(^cancelBlock)(void);

@property (nonatomic, strong) void(^takeShortVideoBlock)(void);

@property (nonatomic, strong) void(^takePhotoBlock)(void);

@property (nonatomic, strong) void(^albumBlock)(void);


+(instancetype)defaultPickerConfig;

@end
