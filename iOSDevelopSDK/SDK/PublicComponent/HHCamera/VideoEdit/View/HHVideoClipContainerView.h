//
//  HHVideoClipContainerView.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/26.
//  Copyright © 2018年 Hayder. All rights reserved.
//  视频截取操作容器视图

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface HHVideoClipContainerView : UIView

// 跳到指定的开始，结束时间
@property (copy, nonatomic) void (^seekToTime)(CGFloat startTime, CGFloat endTime);

// 根据传入的视频URL生成AVAsset对象
@property (nonatomic, strong) AVAsset *videoAvasset;

// 当前播放器对象
@property (strong, nonatomic) AVPlayer *player;

// 取消事件回调
@property (copy, nonatomic) void (^cancelBlock)();
// 完成事件回调
@property (copy, nonatomic) void (^completeBlock)();

@end
