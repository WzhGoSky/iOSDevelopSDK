//
//  HHVideoSessionView.h
//  HHCamera
//
//  Created by Hayder on 2018/10/4.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HHAVKitOption.h"
#import "HHAVKitConfig.h"

@interface HHAVKitManagerView : UIView<AVCaptureFileOutputRecordingDelegate>

//照相机选项
@property (nonatomic, strong, readonly) HHAVKitOption *option;
//切换镜头按钮
@property (nonatomic, strong) UIButton *reverCamera;
//点击拍照或录像定时器
@property (nonatomic, strong) NSTimer *clickTimer;
//点击延时的方法
- (void)addTimerWithTime:(CGFloat)timeGap;
- (void)removeDelayTimer;
//子类重写
- (void)clickDelay;
//初始化方法
- (instancetype)initWithFrame:(CGRect)frame Option:(HHAVKitOption *)option;
//是否是合法的选项 子类实现
- (BOOL)isLegalOption;
//添加界面上的元素 子类重写
- (void)addSubViews;

//展示容器
- (void)showOnContainer:(UIView *)container;
//隐藏
- (void)hideSelf;
#pragma mark ---------------------拍照-----------------------------------------
//拍照
- (void)takePhotoCompletion:(void (^)(UIImage *image)) completion;
#pragma mark ---------------------拍摄视频-----------------------------------------
- (void)startRecord;
- (void)stopRecord;
- (void)quit;
@end
