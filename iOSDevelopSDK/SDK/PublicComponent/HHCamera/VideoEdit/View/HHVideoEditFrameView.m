//
//  HHVideoEditFrameView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/25.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHVideoEditFrameView.h"
#import "HHVideoEditTopFuncView.h"
#import "HHVideoEditBottomFuncView.h"
#import "HHVideoClipContainerView.h"
#import "HHVideoEditService.h"
#import "HHVideoTextMapContainerView.h"
#import "HHVideoTextMapShowContainerView.h"
#import "HHPaintView.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "UIView+HHAdditions.h"
#import "globalDefine.h"
#import "UIView+HUD.h"

@interface HHVideoEditFrameView ()

// 播放容器视图
@property (strong, nonatomic) UIView *playContainerView;

// 顶部功能容器视图
@property (strong, nonatomic) HHVideoEditTopFuncView *topFuncContainerView;

// 底部功能容器视图
@property (strong, nonatomic) HHVideoEditBottomFuncView *bottomFuncContainerView;

// 视频截取操作容器视图
@property (strong, nonatomic) HHVideoClipContainerView *videoClipContainerView;

// 涂鸦界面
@property (strong, nonatomic) HHPaintView *doodleContainerView;

// 文字贴图操作容器视图
@property (strong, nonatomic) HHVideoTextMapContainerView *videoTextMapContainerView;

// 最终要绘制到视频帧的视图容器
@property (strong, nonatomic) UIView *canvasContainerView;

// 播放器
@property (nonatomic, strong) AVPlayer *player;

// 当前的播放Item
@property (strong, nonatomic) AVPlayerItem *playerItem;

// 播放界面Layer
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

// 根据传入的视频URL生成AVAsset对象
@property (nonatomic, strong) AVAsset *videoAvasset;

// 播放器监听定时器
@property (strong, nonatomic) NSTimer *listenPlayerTimer;

// 当前视频开始时间
@property (assign, nonatomic) CGFloat startTime;

// 当前视频结束时间
@property (assign, nonatomic) CGFloat endTime;

@end

@implementation HHVideoEditFrameView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
        [self addObservsers];
        
        [IQKeyboardManager sharedManager].enable = NO;
        [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor blackColor];
    
    self.playContainerView.frame = self.bounds;
    
    self.canvasContainerView.frame = self.bounds;
    
    self.playerLayer.frame = self.bounds;
    
    self.topFuncContainerView.frame = CGRectMake(0, 20, self.width, 44);
    
    self.bottomFuncContainerView.frame = CGRectMake(0, self.height - 88 - 10, self.width, 88);
    
    CGFloat videoClipContainerViewH = 44 + 70;
    self.videoClipContainerView.frame = CGRectMake(0, self.height - videoClipContainerViewH - 10, self.width, videoClipContainerViewH);
}

-  (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
}

#pragma mark - private func
- (void)setupUI {
    
    // 播放容器视图
    self.playContainerView = [[UIView alloc] init];
    [self addSubview:self.playContainerView];
    
    // 最终要绘制到视频帧的视图容器
    self.canvasContainerView = [[UIView alloc] init];
    [self addSubview:self.canvasContainerView];
    
    // 顶部功能视图容器 (取消，完成)
    self.topFuncContainerView = [[HHVideoEditTopFuncView alloc] init];
    __weak typeof(self) ws = self;
    self.topFuncContainerView.cancelBlock = ^{
        
        if (ws.cancelBlock) {
            ws.cancelBlock(ws);
        }
    };
    self.topFuncContainerView.completeBlock = ^{
        
        // 需要渲染画布上的贴图
        if (ws.canvasContainerView.subviews.count > 0) {
            
            [ws showActivityHUDWithDescription:@"渲染中..."];
            
            [ws renderMapsOnCanvasWithCompleteBlock:^(UIImage *image) {
                
                [HHVideoEditService addWaterMaskToVideoAssest:ws.videoAvasset waterMaskImage:image completion:^(NSURL *outputPath, NSError *error) {
                   
                    [ws hideActivityHUD];
                    
                    if (error) {
                        [ws toastMessage:@"视频渲染失败"];
                    }else {
                        if (ws.completeBlock) {
                            
                            ws.completeBlock(outputPath);
                            [ws removeFromSuperview];
                        }
                    }
                }];
            }];
            
        }else {
            
            if (ws.completeBlock) {
                ws.completeBlock(ws.inputPath);
                [ws removeFromSuperview];
            }
        }
        
    };
    [self addSubview:self.topFuncContainerView];
    
    // 底部功能容器视图（画笔，贴图，文字，裁剪
    self.bottomFuncContainerView = [[HHVideoEditBottomFuncView alloc] init];
    
    // 涂鸦
    self.bottomFuncContainerView.doodleBlock = ^(BOOL isSelected){
        
        ws.doodleContainerView.userInteractionEnabled = isSelected;
        
    };
    
    self.bottomFuncContainerView.doodleColorSelectBlock = ^(UIColor *selectColor) {
      
        ws.doodleContainerView.drawingMode = DrawingModePaint;
        ws.doodleContainerView.selectedColor = selectColor;
    };
    
    self.bottomFuncContainerView.doodleDrawModeSelectBlock = ^(DrawingMode drawingMode) {
      
        ws.doodleContainerView.drawingMode = drawingMode;
    };
    
    //文字贴图
    self.bottomFuncContainerView.textMapBlock = ^{
        
        [ws.videoTextMapContainerView clearTextView];
        ws.videoTextMapContainerView.isFromTextMapShowView = NO;
        [ws.videoTextMapContainerView callOutKeyboard];
        
        ws.bottomFuncContainerView.hidden = YES;
        ws.topFuncContainerView.hidden = YES;
    };
    
    // 视频裁剪
    self.bottomFuncContainerView.clipBlock = ^{
        
        [ws addClipContainerView];
        ws.bottomFuncContainerView.hidden = YES;
        ws.topFuncContainerView.hidden = YES;
    };
    [self addSubview:self.bottomFuncContainerView];
    
}

- (void)startListenPlayerTimer {
    
    [self removeListenPlayerTimer];
    self.listenPlayerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onPlayerTimerCallBack) userInfo:nil repeats:YES];
}

- (void)removeListenPlayerTimer {
    
    if (self.listenPlayerTimer) {
        
        [self.listenPlayerTimer invalidate];
        self.listenPlayerTimer = nil;
    }
}

- (void)onPlayerTimerCallBack {
    
    CGFloat currentTime = CMTimeGetSeconds([self.player currentTime]);
    
    if (currentTime >= self.endTime) {
        
        [self seekToTime:self.startTime];
    }
}

- (void)seekToTime:(CGFloat)startTime {
    
    int32_t timeScale = self.player.currentTime.timescale;
    
    [self.player seekToTime:CMTimeMakeWithSeconds(startTime, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)resetPlayView {
    
    self.startTime = 0;
    self.endTime = 0;
    _player = nil;
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
    [self removeListenPlayerTimer];
}

- (void)addObservsers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)onKeyboardWillChangeFrame:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    CGFloat animationDuration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    CGRect currentKeyboardRect = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat keyboardHeight = currentKeyboardRect.size.height;
    
    self.videoTextMapContainerView.height = SCREEN_HEIGHT - keyboardHeight;
    [UIView animateWithDuration:animationDuration animations:^{
        
        self.videoTextMapContainerView.top = (currentKeyboardRect.origin.y - SCREEN_HEIGHT) == 0 ? SCREEN_HEIGHT : 0;
        if (self.videoTextMapContainerView.top == SCREEN_HEIGHT) {
            self.bottomFuncContainerView.hidden = NO;
            self.topFuncContainerView.hidden = NO;
        }
    }];
}

// 添加文字贴图显示视图
- (void)addTextMapShowViewWithTextView:(UITextView *)textView {
    
    __weak typeof(self) ws = self;
    HHVideoTextMapShowContainerView *textMapShowView = [[HHVideoTextMapShowContainerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    textMapShowView.center = self.canvasContainerView.center;
    textMapShowView.textView = textView;
    textMapShowView.longPressBlock = ^(HHVideoTextMapShowContainerView *textMapShowContainerView) {
      
        [textMapShowContainerView removeFromSuperview];
        textMapShowContainerView = nil;
    };
    
    textMapShowView.doubleClickBlock = ^(HHVideoTextMapShowContainerView *textMapShowView, NSString *text, UIColor *textColor) {
        
        ws.videoTextMapContainerView.isFromTextMapShowView = YES;
        
        [ws.videoTextMapContainerView callOutKeyboard];
        
        [ws.videoTextMapContainerView setText:text textColor:textColor textMapShowView:textMapShowView];
    };
    
    [self.canvasContainerView addSubview:textMapShowView];
}

- (void)renderMapsOnCanvasWithCompleteBlock:(void (^)(UIImage * image))completeBlock {
    
    UIGraphicsBeginImageContextWithOptions(self.canvasContainerView.size, NO, [UIScreen mainScreen].scale);
    
    [self.canvasContainerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_get_main_queue(), ^{

        if (completeBlock)
        {
            completeBlock(snapshotImage);
        }
    });
}

+ (UIImage *)renderViewAsImageWithView:(UIView *)subView {
    
    CGSize size = subView.size;
    CGFloat scaleX = [[subView.layer valueForKey:@"transform.scale.x"] floatValue];
    CGFloat scaleY = [[subView.layer valueForKey:@"transform.scale.y"] floatValue];
    CGSize targetSize = CGSizeMake(size.width * scaleX, size.height * scaleY);
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    [subView drawViewHierarchyInRect:CGRectMake(0, 0, targetSize.width, targetSize.height) afterScreenUpdates:NO];
    CGContextRestoreGState(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)onPlayerItemDidPlayToEndTime:(NSNotification *)notification
{
    AVPlayerItem *item = (AVPlayerItem *)notification.object;
    if (self.playerItem == item) {
        
        [self.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.videoAvasset.duration.timescale)];
        [self.player play];
    }
}

- (void)addClipContainerView {
    
    self.videoClipContainerView = [[HHVideoClipContainerView alloc] init];
    
    self.videoClipContainerView.videoAvasset = self.videoAvasset;
    
    self.videoClipContainerView.player = self.player;
    
    __weak typeof(self) ws = self;
    self.videoClipContainerView.cancelBlock = ^{
        
        [ws.videoClipContainerView removeFromSuperview];
        ws.videoClipContainerView = nil;
        ws.bottomFuncContainerView.hidden = NO;
        ws.topFuncContainerView.hidden = NO;
        
        ws.startTime = 0;
        ws.endTime = CMTimeGetSeconds(ws.videoAvasset.duration);
        
        [ws seekToTime:ws.startTime];
    };
    
    self.videoClipContainerView.completeBlock = ^{
        
        [ws toastMessage:@"视频裁剪中"];
        
        [HHVideoEditService clipVideoWithVideoAssest:ws.videoAvasset startTime:ws.startTime endTime:ws.endTime completion:^(NSURL *outputPath, NSError *error) {
            
            [ws hideActivityHUD];
            
            if (error) {
                
                [ws toastMessage:@"裁剪失败"];
            }else {
                
                [ws.videoClipContainerView removeFromSuperview];
                ws.videoClipContainerView = nil;
                ws.bottomFuncContainerView.hidden = NO;
                ws.topFuncContainerView.hidden = NO;
                
                [ws resetPlayView];
                [ws setInputPath:outputPath];
            }
        }];
    };
    
    self.videoClipContainerView.seekToTime = ^(CGFloat startTime, CGFloat endTime) {
        
        ws.startTime = startTime;
        ws.endTime = endTime;
        
        [ws seekToTime:startTime];
    };
    [self addSubview:self.videoClipContainerView];
}

#pragma mark - getter,setter
- (void)setInputPath:(NSURL *)inputPath {
    
    // 每次设置时，移除对之前的playItem的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    _inputPath = inputPath;
    
    self.videoAvasset = [AVAsset assetWithURL:inputPath];
    
    CMTime videoDuration = self.videoAvasset.duration;
    
    self.endTime = CMTimeGetSeconds(videoDuration);
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.videoAvasset];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.playContainerView.layer addSublayer:self.playerLayer];
    
    [self.player play];
    
    // 添加新的playItem的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

- (HHVideoTextMapContainerView *)videoTextMapContainerView {
    
    if (!_videoTextMapContainerView) {
        
        _videoTextMapContainerView = [[HHVideoTextMapContainerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0)];
        
        __weak typeof(self) ws = self;
        _videoTextMapContainerView.cancelBlock = ^{
            
            [ws endEditing:YES];
            ws.bottomFuncContainerView.hidden = NO;
            ws.topFuncContainerView.hidden = NO;
        };
        
        _videoTextMapContainerView.completeBlock = ^(UITextView *textView) {
            
            [ws endEditing:YES];
            [ws addTextMapShowViewWithTextView:textView];
            ws.bottomFuncContainerView.hidden = NO;
            ws.topFuncContainerView.hidden = NO;
            textView.text = nil;
        };
        
        [self addSubview:_videoTextMapContainerView];
    }
    return _videoTextMapContainerView;
}

- (HHPaintView *)doodleContainerView {
    
    if (!_doodleContainerView) {
        
        _doodleContainerView = [[HHPaintView alloc] initWithFrame:self.canvasContainerView.frame];
        
        _doodleContainerView.backgroundColor = [UIColor clearColor];
        
        [self.canvasContainerView addSubview:_doodleContainerView];
    }
    return _doodleContainerView;
}
@end
