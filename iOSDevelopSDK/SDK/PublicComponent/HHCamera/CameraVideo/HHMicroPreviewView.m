//
//  HHMicro previewPreviewView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/6/6.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHMicroPreviewView.h"
#import "HHCameraHelper.h"
#import "HHAVKitConfig.h"

@interface HHMicroPreviewView()

@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, strong) UIButton *backBtn;

@property (strong, nonatomic) UIButton *editBtn;

@end

@implementation HHMicroPreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _selfFrame = frame;
        self.backgroundColor = [UIColor blackColor];
        [self addSubviews];
        [self configSubviews];
        [self relayoutSubViews];
//        // 可能会监听到别的播放器
//        [self addObserver];
    }
    return self;
}

//- (void)addObserver
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEndPlay:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playItem];
//}

- (void)addSubviews
{
    _playerLayer = [AVPlayerLayer layer];
    [self.layer addSublayer:_playerLayer];
}

- (void)backBtnEvent:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(microPreviewViewDidClickBackBtn:)]) {
        
        [self.delegate microPreviewViewDidClickBackBtn:self];
    }
}

- (void)sureBtnEven:(UIButton *)btn
{
    [self removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(microPreviewViewDidClickSureBtn:)]) {
        [self.delegate microPreviewViewDidClickSureBtn:self];
    }
}

- (void)onEditBtnClick {
    
    if ([self.delegate respondsToSelector:@selector(microPreviewViewDidClickEditBtn:)]) {
        [self.delegate microPreviewViewDidClickEditBtn:self];
    }
}

- (void)configSubviews
{
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _playerLayer.masksToBounds = YES;
}

- (void)setFilePath:(NSString *)filePath
{
    _filePath = filePath;
    
    _videoURL = [NSURL fileURLWithPath:filePath];
    [self initPlayer];
    
    [_player play];
}

- (void)initPlayer
{
    // 每次设置时，移除对之前的playItem的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playItem];
    
    _playItem = [AVPlayerItem playerItemWithURL:_videoURL];
    _player   = [AVPlayer playerWithPlayerItem:_playItem];
    
    [_playerLayer setPlayer:_player];
    
    // 添加新的playItem的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEndPlay:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playItem];
}

-(void)onEndPlay:(NSNotification *)notification
{
    AVPlayerItem *item = (AVPlayerItem *)notification.object;
    if (_playItem == item)
    {
        [_player seekToTime:CMTimeMake(0, 1)];
        
        [_player play];
    }
}

- (void)relayoutSubViews
{
    _playerLayer.frame = self.bounds;
}


/**
 布局按钮
 */
- (void)layoutBtns
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width/3;
    CGFloat heigth = width;
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:[UIImage imageNamed:@"Micro_pre_delete"] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backBtn];
    
    if (self.currentTime <= self.option.showEditButtonTime) {
        self.editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.editBtn setImage:[UIImage imageNamed:@"Micro_pre_edit"] forState:UIControlStateNormal];
        [self.editBtn addTarget:self action:@selector(onEditBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.editBtn];
    }
    
    self.sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sureBtn setImage:[UIImage imageNamed:@"Micro_pre_complete"] forState:UIControlStateNormal];
    [self.sureBtn addTarget:self action:@selector(sureBtnEven:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sureBtn];
    
    self.backBtn.frame = CGRectMake(width, self.frame.size.height-heigth, width, heigth);
    self.editBtn.frame = CGRectMake(width, self.frame.size.height-heigth, width, heigth);
    self.sureBtn.frame = CGRectMake(width, self.frame.size.height-heigth, width, heigth);
    
    [UIView animateWithDuration:0.25 animations:^{
        [self setX:0 View:self.backBtn];
        [self setX:width View:self.editBtn];
        [self setX:2*width View:self.sureBtn];
    }];
}

- (void)setX:(CGFloat)x View:(UIView *)view
{
    CGRect frame = view.frame;
    frame.origin.x = x;
    view.frame = frame;
}


- (void)hideBottomBtns {
    
    self.backBtn.hidden = self.editBtn.hidden = self.sureBtn.hidden = YES;
}

- (void)showBottomBtns {
    
    self.backBtn.hidden = self.editBtn.hidden = self.sureBtn.hidden = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _videoURL = nil;
    _playItem = nil;
    _player = nil;
    _playerLayer = nil;
}

- (void)stop
{
    [self.player pause];
}

- (void)resume
{
    [self.player play];
}

@end
