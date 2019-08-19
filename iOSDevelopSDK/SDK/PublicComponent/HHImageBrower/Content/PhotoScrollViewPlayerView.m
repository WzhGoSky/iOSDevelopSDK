//
//  PhotoScrollViewPlayerView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/8/7.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "PhotoScrollViewPlayerView.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface PhotoScrollViewPlayerView()
{
    id  _playTimeObserver;
}
@property (strong, nonatomic)AVPlayer * player;
@property (strong, nonatomic)AVPlayerItem * playerItem;
@property (strong, nonatomic)AVPlayerLayer * playerLayer;
@end

@implementation PhotoScrollViewPlayerView

- (void)dealloc
{
    [self removeObserverAndNotification];
    [self removeObserverPlayerItem];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}
#pragma mark
-(void)setIsMute:(BOOL)isMute{
    _isMute = isMute;
    [self.player setMuted:isMute];
}
- (AVPlayer *)player
{
    if (!_player) {
        _player = [[AVPlayer alloc]init];
    }
    return _player;
}
- (id)init
{
    if (self = [super init])
    {
        [self loadUI];
        [self addObserverPlayer];
        [self addNSNotificationCenter];
        [self addClickTap];
    }
    return self;
}

-(NSTimeInterval)currentPlayTime{
    CMTime time = self.player.currentTime;
    NSTimeInterval currentTimeSec = time.value / time.timescale;
    return currentTimeSec;
}

-(void)setVideoGravity:(AVLayerVideoGravity)videoGravity{
    _videoGravity = videoGravity;
    self.playerLayer.videoGravity = videoGravity;
}

- (void)loadUI
{
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:self.playerLayer];
}

- (void) addClickTap{
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickPlayerLayer:)];
//    [self addGestureRecognizer:tap];
}

- (void)setPlayUrl:(NSString *)stringURL
{
    if (!stringURL) {
        NSLog(@"======没有可播放的视频资源======");
        return;
    }
    if (self.playerItem) {
        [self removeObserverPlayerItem];
    }
    NSURL * url;
    if ([stringURL rangeOfString:@"/"].location == 0) {
        //本地
        url = [NSURL fileURLWithPath:stringURL isDirectory:NO];
    }
    else
    {
        url = [NSURL URLWithString:stringURL];
    }
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    [self addPeriodicTimeObserver:self.playerItem];
    [self addObserverPlayerItem];
    [MBProgressHUD showHUDAddedTo:self animated:YES];
}
#pragma mark NSNotificationCenter
//添加监听状态
- (void)addObserverPlayerItem
{
    //加载状态改变通知
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //缓冲进度，可有可无，可以增加用户体验
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //缓冲为空
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓冲可以播放的时候调用
    [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    //缓冲完成
    [_playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)addObserverPlayer
{
    /* 监听 AVPlayer "currentItem" 属性*/
    [self.player addObserver:self   forKeyPath:@"currentItem"   options:NSKeyValueObservingOptionNew    context:nil];
    /* 监听 AVPlayer "rate" 属性 以便我们去更新播放进度控件. rate = 0暂停 rate = 1 播放*/
    [self.player addObserver:self   forKeyPath:@"rate"  options:NSKeyValueObservingOptionNew    context:nil];
}
//添加通知
- (void)addNSNotificationCenter
{
    //播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
//移除监听
- (void)removeObserverAndNotification{
    
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [self.player removeObserver:self forKeyPath:@"currentItem"];
    [self.player removeObserver:self forKeyPath:@"rate"];
    if (_playTimeObserver) {
        [self.player removeTimeObserver:_playTimeObserver];
        _playTimeObserver = nil;
    }
    self.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
- (void)removeObserverPlayerItem
{
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
}

#pragma mark

#pragma mark - KVO - status
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        [MBProgressHUD hideHUDForView:self animated:YES];
        AVPlayerItemStatus type = _playerItem.status;
        switch (type) {
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"======视频可以开始播放=====");
                CMTime duration = item.duration;// 获取视频总长度
                self.duration = CMTimeGetSeconds(duration);
                [self AVPlayerPlayStatus:AVPlayerPlayStatePreparing];
            }break;
            case AVPlayerStatusUnknown:
            {
                [self AVPlayerPlayStatus:AVPlayerPlayStateNotKnow];
            }break;
            case AVPlayerStatusFailed:
            {
                NSLog(@"=====音频解析出错=====");
                [self AVPlayerPlayStatus:AVPlayerPlayStateNotPlay];
            }break;
            default:
                break;
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray * loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];//获取缓冲区域
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval result = startSeconds + durationSeconds;//计算缓冲总进度
        if ([self.delegate respondsToSelector:@selector(AVPlayerDidBufferProgress:)]) {
            [self.delegate AVPlayerDidBufferProgress:result];
        }
    }else if([keyPath isEqualToString:@"playbackBufferFull"])
    {
        [self AVPlayerPlayStatus:AVPlayerPlayStateBufferFull];
    }
    else if([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        [self AVPlayerPlayStatus:AVPlayerPlayStateBufferEmpty];
        [MBProgressHUD showHUDAddedTo:self animated:YES];

    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        [self AVPlayerPlayStatus:AVPlayerPlayStateBufferToKeepUp];
        [MBProgressHUD hideHUDForView:self animated:YES];
    }
    else if ([keyPath isEqualToString:@"rate"])
    {
        if (self.duration == 0) {
            return;
        }
        if (self.player.rate == 0) {
            [self AVPlayerPlayStatus:AVPlayerPlayStatePause];
        }
        if (self.player.rate ==1) {
            [self AVPlayerPlayStatus:AVPlayerPlayStatePlaying];
        }
    }
    else if ([keyPath isEqualToString:@"currentItem"])
    {
        [self AVPlayerPlayStatus:AVPlayerPlayStateBufferToKeepUp];
    }
}

- (void)didClickPlayerLayer:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(AVPlayerDidClick)]) {
        [self.delegate AVPlayerDidClick];
    }
}

- (void)addPeriodicTimeObserver:(AVPlayerItem *)playerItem
{
    //这里设置每秒执行1次
//    @weakify(self)
    __weak typeof(self) wself = self;
    _playTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1,2.0f) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(self) sSelf = wself;
//        @strongify(self)
        // 计算当前在第几秒
        NSTimeInterval timeInSeconds = CMTimeGetSeconds(time);
        if (timeInSeconds > 0) {
            [MBProgressHUD hideHUDForView:sSelf animated:YES];
        }
        if ([sSelf.delegate respondsToSelector:@selector(AVPlayerDidProgress:)]) {
            [sSelf.delegate AVPlayerDidProgress:timeInSeconds];
        }
        
    }];
}
-(void)playbackFinished:(NSNotification *)notification{
    [self AVPlayerPlayStatus:AVPlayerPlayStateEnd];
    
}
- (void)AVPlayerPlayStatus:(AVPlayerPlayState )status
{
    if ([self.delegate respondsToSelector:@selector(AVPlayerPlayStatusChange:)])
    {
        [self.delegate AVPlayerPlayStatusChange:status];
    }
}
#pragma mark

- (void)setInitialPlaybackTime:(NSTimeInterval)initialPlaybackTime
{
    if (_playerItem) {
        CMTime dragedCMTime = CMTimeMake(initialPlaybackTime, 1);
        [_playerItem seekToTime:dragedCMTime];
    }
}

- (BOOL)isPlaying
{   //rate ==1.0，表示正在播放；rate == 0.0，暂停；rate == -1.0，播放失败
    if (self.player.rate > 0 && !self.player.error) {
        return YES;
        
    } else {
        return NO;
    }
}
- (void)play
{
    if (self.player) {
        [self.player play];
    }
}
- (void)pause
{
    if (self.player) {
        [self.player pause];
    }
}
- (void)stop
{
    if (self.player) {
        [self.player pause];
    }
}

@end
