//
//  PhotoScrollViewPlayerView.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/8/7.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger,AVPlayerPlayState) {
    
    AVPlayerPlayStatePreparing = 0x0,// 准备播放
    AVPlayerPlayStateStart,        // 开始播放
    AVPlayerPlayStatePlaying,      // 正在播放
    AVPlayerPlayStatePause,        // 播放暂停
    AVPlayerPlayStateEnd,          // 播放结束
    AVPlayerPlayStateBufferEmpty,  // 没有缓存的数据供播放了 需要时间加载
    AVPlayerPlayStateBufferToKeepUp,//有缓存的数据可以供播放
    AVPlayerPlayStateBufferFull,//缓冲完成；
    
    AVPlayerPlayStateNotPlay,      // 不能播放
    AVPlayerPlayStateNotKnow       // 未知情况
};
@protocol AVPlayerManagerDelegate <NSObject>

//播放状态变更
- (void)AVPlayerPlayStatusChange:(AVPlayerPlayState)status;
//播放进度
- (void)AVPlayerDidProgress:(NSTimeInterval)value;
//缓冲进度
- (void)AVPlayerDidBufferProgress:(NSTimeInterval)value;
//点击视屏
- (void)AVPlayerDidClick;
@end

@interface PhotoScrollViewPlayerView : UIView
//音频总长度
@property (assign, nonatomic) NSTimeInterval duration;
//当前播放长度
@property (assign, nonatomic) NSTimeInterval currentPlayTime;
//设置视频播放位置
@property (assign, nonatomic) NSTimeInterval initialPlaybackTime;

@property (weak, nonatomic) id<AVPlayerManagerDelegate>delegate;

//设置缩放模式
@property (nonatomic, strong)  AVLayerVideoGravity videoGravity;

/**
 是否静音
 */
@property (nonatomic, assign) BOOL isMute;

- (void)setPlayUrl:(NSString *)stringURL;

- (BOOL)isPlaying;

- (void)play;

- (void)pause;

- (void)stop;

@end
