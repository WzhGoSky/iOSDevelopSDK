//
//  HHCamera.h
//  HHCamera
//
//  Created by Hayder on 2018/10/4.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHAVKitManagerView.h"
#import "HHCameraPhoto.h"

@class HHNormalCamera;
@protocol HHNormalCameraDelegate <NSObject>

- (void)normalCamera:(HHNormalCamera *)camera didFinishedTakingPhoto:(NSArray *)photos;

@end

@interface HHNormalCamera : HHAVKitManagerView
//拍照按钮
@property (nonatomic, strong)  UIButton  *takePhotoBtn;
//取消按钮
@property (nonatomic, strong)  UIButton  *cancelBtn;
//确认按钮
@property (nonatomic, strong) UIButton *sureBtn;
//是否使用本地缓存策略 默认yes
@property (nonatomic, assign) BOOL isUseLocalCacheProlicy;

@property (nonatomic, weak) id<HHNormalCameraDelegate> delegate;

//拍照结束 子类可对照片进行编辑
- (UIImage *)takePhotoEndWithImage:(UIImage *)originalImage;

@end
