//
//  HHMicro previewPreviewView.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/6/6.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HHAVKitOption.h"

@class HHMicroPreviewView;
@protocol HHMicroPreviewViewDelegate <NSObject>

@optional
- (void)microPreviewViewDidClickBackBtn:(HHMicroPreviewView *)microPreviewView;
@optional
- (void)microPreviewViewDidClickSureBtn:(HHMicroPreviewView *)microPreviewView;
@optional
- (void)microPreviewViewDidClickEditBtn:(HHMicroPreviewView *)microPreviewView;

@end

@interface HHMicroPreviewView : UIView
{
    NSURL   *_videoURL;
    AVPlayerItem    *_playItem;
    AVPlayerLayer   *_playerLayer;
    BOOL            _isPlaying;
    
    CGRect          _selfFrame;
}

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (strong, nonatomic) AVPlayer *player;

@property (nonatomic, strong) HHAVKitOption *option;
/**
 视频的路径
 */
@property (nonatomic, strong) NSString *filePath;

/**视频的实际秒数*/
@property (nonatomic, assign) NSInteger currentTime;

@property (nonatomic, weak) id<HHMicroPreviewViewDelegate> delegate;

/**
 布局按钮
 */
- (void)layoutBtns;

- (void)hideBottomBtns;

- (void)showBottomBtns;

- (void)stop;
- (void)resume;

@end
