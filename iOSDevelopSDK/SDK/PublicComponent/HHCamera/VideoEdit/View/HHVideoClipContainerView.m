//
//  HHVideoClipContainerView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/26.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHVideoClipContainerView.h"
#import "HHVideoClipOperationView.h"
#import "HHVideoEditTopFuncView.h"
#import "UIView+HHAdditions.h"
#import <AVFoundation/AVFoundation.h>

@interface HHVideoClipContainerView ()

// 底部取消，完成按钮容器视图
@property (strong, nonatomic) HHVideoEditTopFuncView *funcBtnView;

// 裁剪操作视图
@property (strong, nonatomic) HHVideoClipOperationView *clipOperationView;

@end

@implementation HHVideoClipContainerView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.funcBtnView.frame = CGRectMake(0, self.height - 44, self.width, 44);
    
    self.clipOperationView.frame = CGRectMake(0, 0, self.width, self.height - 44);
}

#pragma mark - private func
- (void)setupUI {
    
    self.funcBtnView = [[HHVideoEditTopFuncView alloc] init];
    
    __weak typeof(self) ws = self;
    self.funcBtnView.cancelBlock = ^{
        if (ws.cancelBlock) {
            ws.cancelBlock();
        }
    };
    self.funcBtnView.completeBlock = ^{
        if (ws.completeBlock) {
            ws.completeBlock();
        }
    };
    
    [self addSubview:self.funcBtnView];
    
    self.clipOperationView = [[HHVideoClipOperationView alloc] init];
    self.clipOperationView.seekToTime = ^(CGFloat startTime, CGFloat endTime) {
        if (ws.seekToTime) {
            ws.seekToTime(startTime, endTime);
        }
    };
    [self addSubview:self.clipOperationView];
}

#pragma mark - getter,setter
- (void)setVideoAvasset:(AVAsset *)videoAvasset {
    
    _videoAvasset = videoAvasset;
    
    self.clipOperationView.videoAvasset = videoAvasset;
}

- (void)setPlayer:(AVPlayer *)player {
    
    _player = player;
    
    self.clipOperationView.player = player;
}
@end
