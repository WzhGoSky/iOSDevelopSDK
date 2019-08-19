//
//  HHCameraHelper.h
//  HHCamera
//
//  Created by Hayder on 2018/10/5.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HHAVKitConfig.h"

typedef NS_ENUM(NSInteger, SessionType) {
    SessionTypePhoto,
    SessionTypeVideo
};

typedef NS_ENUM(NSInteger, SessionPreset) {
    SessionPresetLow,
    SessionPresetMedium,
    SessionPresetHigh
};

typedef NS_ENUM(NSInteger, QualityLevel) {
    QualityLevelMedium,//中等画质
    QualityLevelHigh,//高
    QualityLevelLow//低
};


@interface HHCameraHelper : NSObject
// tint只对里面的图案作更改颜色操作
+ (UIImage *)image:(UIImage *)image WithTintColor:(UIColor *)tintColor;
+ (UIImage *)image:(UIImage *)image WithGradientTintColor:(UIColor *)tintColor;
+ (UIImage *)image:(UIImage *)image WithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;
//转码
+ (void)convertToMP4:(QualityLevel)qualityLevel avAsset:(AVURLAsset*)avAsset videoPath:(NSString*)videoPath succ:(void (^)(NSString *resultPath))succ fail:(void (^)(void))fail;
//将图片存储到cache中
+ (void)saveImageToFile:(UIImage *)image;

//删除缓存
+ (void)deleteCacheImages;

//创建照片缓存文件夹
+ (void)createCacheFloder;

+ (void)showWaitingDialogWithMsg:(NSString *)msg container:(UIView *)containerView;

+ (void)dismissWaitingDialogOnContainer:(UIView *)containerView;

+ (void)showMessage:(NSString *)msg container:(UIView *)containerView;


@end
