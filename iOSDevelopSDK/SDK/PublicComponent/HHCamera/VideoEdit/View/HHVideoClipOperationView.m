//
//  HHVideoClipOperationView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/26.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHVideoClipOperationView.h"
#import "HHVideoClipSliderBlockBtn.h"
#import "UIView+HHAdditions.h"
#import "globalDefine.h"

static CGFloat kMargin = 40;

@interface HHVideoClipOperationView ()

// 视频桢的容器视图
@property (strong, nonatomic) UIView *videoFrameContainerView;

// 视频桢容器视图中间移动的白线
@property (strong, nonatomic) UIView *videoFrameTrackView;

// 左边的当前选择区间之外的覆盖物
@property (strong, nonatomic) UIView *leftOverlayView;

// 右边的当前选择区间之外的覆盖物
@property (strong, nonatomic) UIView *rightOverlayView;

// 视频桢容器视图中左边滑块
@property (strong, nonatomic) HHVideoClipSliderBlockBtn *leftSliderBtn;

// 视频桢容器视图中右边滑块
@property (strong, nonatomic) HHVideoClipSliderBlockBtn *rightSliderBtn;

// 左边的滑块的上一次触摸点
@property (nonatomic, assign) CGPoint leftPrePoint;

// 右边的滑块的上一次触摸点
@property (nonatomic, assign) CGPoint rightPrePoint;

// 生成缩略图的类
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

// 中间移动的白线定时器
@property (strong, nonatomic) NSTimer *trackTimer;

// 当前视频开始时间
@property (assign, nonatomic) CGFloat startTime;

// 当前视频结束时间
@property (assign, nonatomic) CGFloat endTime;


@end

@implementation HHVideoClipOperationView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.videoFrameContainerView.frame = CGRectMake(kMargin, 0, self.width - kMargin * 2, self.height);
    
    CGFloat overlayViewW = SCREEN_WIDTH;
    
    CGFloat sliderBtnW = 20;
    
    self.leftOverlayView.frame = CGRectMake( -overlayViewW + kMargin, 0, overlayViewW, self.height);
    
    self.rightOverlayView.frame = CGRectMake(SCREEN_WIDTH - kMargin, 0, overlayViewW, self.height);
    
    self.leftSliderBtn.frame = CGRectMake(overlayViewW - sliderBtnW, 0, sliderBtnW, self.height);
    
    self.rightSliderBtn.frame = CGRectMake(0, 0, sliderBtnW, self.height);
    
    self.videoFrameTrackView.frame = CGRectMake(CGRectGetMaxX(self.leftOverlayView.frame), 0, 1, self.height);
    
    // 设置每一帧的位置
    NSInteger frameImagesCount = self.videoFrameContainerView.subviews.count;
    
    CGFloat frameImageViewW = self.videoFrameContainerView.width / 10;
    CGFloat frameImageViewH = self.videoFrameContainerView.height;
    
    for (NSInteger i = 0; i < frameImagesCount; i++) {
        UIImageView *imageView = self.videoFrameContainerView.subviews[i];
        imageView.frame = CGRectMake(i * frameImageViewW, 0, frameImageViewW, frameImageViewH);
    }
}

- (void)dealloc {
    
    NSLog(@"111232313");
    [self cancelTrackTimer];
}

#pragma mark - private func
- (void)setupUI {
    
    // 视频桢容器视图
    self.videoFrameContainerView = [[UIView alloc] init];
    self.videoFrameContainerView.clipsToBounds = YES;
    self.videoFrameContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.videoFrameContainerView.layer.borderWidth = 1;
    [self addSubview:self.videoFrameContainerView];
    
    // 视频桢容器视图中间移动的白线
    self.videoFrameTrackView = [[UIView alloc] init];
    self.videoFrameTrackView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.videoFrameTrackView];
    
    // 左边的当前选择区间之外的覆盖物
    self.leftOverlayView = [[UIView alloc] init];
    self.leftOverlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftPanAction:)];
    [self.leftOverlayView addGestureRecognizer:leftPan];
    [self addSubview:self.leftOverlayView];
    
    // 视频桢容器视图中左边滑块
    self.leftSliderBtn = [[HHVideoClipSliderBlockBtn alloc] init];
    self.leftSliderBtn.isLeftSliderBtn = YES;
    [self.leftOverlayView addSubview:self.leftSliderBtn];
    
    // 右边的当前选择区间之外的覆盖物
    self.rightOverlayView = [[UIView alloc] init];
    self.rightOverlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightPanAction:)];
    [self.rightOverlayView addGestureRecognizer:rightPan];
    [self addSubview:self.rightOverlayView];
    
    // 视频桢容器视图中右边滑块
    self.rightSliderBtn = [[HHVideoClipSliderBlockBtn alloc] init];
    self.rightSliderBtn.isLeftSliderBtn = NO;
    [self.rightOverlayView addSubview:self.rightSliderBtn];
}

- (void)generateThumImages {
    
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.videoAvasset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    
    NSInteger thumImageCount = 10;
    CMTime videoDuration = self.videoAvasset.duration;
    CGFloat oneScetionDuration = CMTimeGetSeconds(videoDuration) / thumImageCount;
    
    NSMutableArray <NSValue *> *timesArr = [NSMutableArray array];
    NSMutableArray *imageFrameArr = [NSMutableArray array];
    
    for (NSInteger i = 0; i < thumImageCount; i++) {
        
        CMTime oneSectionCMTime = CMTimeMakeWithSeconds(i * oneScetionDuration, self.videoAvasset.duration.timescale);
        [timesArr addObject:[NSValue valueWithCMTime:oneSectionCMTime]];
        [imageFrameArr addObject:[NSNull null]];
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    for (NSInteger i = 0; i < thumImageCount; i++) {
        
        dispatch_group_enter(group);
        
        CMTime time = [timesArr[i] CMTimeValue];
        
        CGImageRef imageRef = [self.imageGenerator copyCGImageAtTime:time actualTime:NULL error:nil];
        
        imageFrameArr[i] = [UIImage imageWithCGImage:imageRef];
        
        CGImageRelease(imageRef);
        
        dispatch_group_leave(group);
    }
    
    __weak typeof(self) ws = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        for (UIImage *image in imageFrameArr) {
            
            UIImageView *frameImageView = [[UIImageView alloc] init];
            frameImageView.image = image;
            [ws.videoFrameContainerView addSubview:frameImageView];
        }
        [ws setNeedsLayout];
    });
}

- (void)seekVideo {
    
    self.startTime = (CGRectGetMaxX(self.leftOverlayView.frame) - kMargin) / self.videoFrameContainerView.width * CMTimeGetSeconds(self.videoAvasset.duration);
    
    self.endTime = (self.rightOverlayView.left - kMargin) / self.videoFrameContainerView.width * CMTimeGetSeconds(self.videoAvasset.duration);
    
    if (self.seekToTime) {
        
        self.seekToTime(self.startTime, self.endTime);
    }
}

- (void)startTrackTimer {
    
    [self cancelTrackTimer];
    
    __weak typeof(self) ws = self;
    self.trackTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        CGFloat currentTime = CMTimeGetSeconds(ws.player.currentTime);
        
        if (ws.videoFrameTrackView.left >= ws.rightOverlayView.left) {
            
            ws.videoFrameTrackView.left = CGRectGetMaxX(ws.leftOverlayView.frame);
            [ws seekVideo];
        }else {
            
            CGFloat frameTrackViewX = currentTime / CMTimeGetSeconds(ws.videoAvasset.duration) * ws.videoFrameContainerView.width + kMargin;
            ws.videoFrameTrackView.left = frameTrackViewX;
        }
        
//        if (currentTime >= ws.endTime) {
//            frameTrackViewX = ws.startTime / CMTimeGetSeconds(ws.videoAvasset.duration) * ws.videoFrameContainerView.width + kMargin;
//            [ws seekVideo];
//
//        }else {
//            frameTrackViewX = currentTime / CMTimeGetSeconds(ws.videoAvasset.duration) * ws.videoFrameContainerView.width + kMargin;
//        }
//        ws.videoFrameTrackView.x = frameTrackViewX;
    }];
}

- (void)cancelTrackTimer {
    
    [self.trackTimer invalidate];
    self.trackTimer = nil;
}

#pragma mark - getter,setter
- (void)setVideoAvasset:(AVAsset *)videoAvasset {
    
    _videoAvasset = videoAvasset;
    
    self.startTime = 0;
    self.endTime = CMTimeGetSeconds(videoAvasset.duration);
    
    [self generateThumImages];
    
    [self startTrackTimer];
}

- (void)setPlayer:(AVPlayer *)player {
    
    _player = player;
    
}

#pragma mark - event respond
- (void)leftPanAction:(UIPanGestureRecognizer *)gesture {
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.leftPrePoint = [gesture locationInView:self];
            self.videoFrameTrackView.hidden = YES;
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self];
            // 偏移量X
            int offSetX = point.x - self.leftPrePoint.x;
            
            self.leftOverlayView.centerX += offSetX;
            
            CGFloat frameImageContainerW = (SCREEN_WIDTH - kMargin * 2);
            CGFloat onSectionFrameW = frameImageContainerW / 10;
            CGFloat maxRightMoveLenght = onSectionFrameW * 3 + kMargin;
            
            if (self.rightOverlayView.centerX - self.leftOverlayView.centerX - SCREEN_WIDTH <= 3 * onSectionFrameW) {
                self.leftOverlayView.centerX = self.rightOverlayView.centerX - SCREEN_WIDTH - 3 * onSectionFrameW;
            }
            
            // 左边滑块超过左滑的最大位置
            if ( (-SCREEN_WIDTH * 0.5 + kMargin) >= self.leftOverlayView.centerX) {
                self.leftOverlayView.centerX = -SCREEN_WIDTH * 0.5 + kMargin;
            }
            
            // 左边滑块超过右滑的最大位置
            if (self.leftOverlayView.centerX >= (SCREEN_WIDTH * 0.5 - maxRightMoveLenght)) {
                self.leftOverlayView.centerX = SCREEN_WIDTH * 0.5 - maxRightMoveLenght;
            }
            
            self.leftPrePoint = point;
            [self seekVideo];
            self.videoFrameTrackView.hidden = YES;
            break;
        }
        case UIGestureRecognizerStateEnded:
            self.videoFrameTrackView.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)rightPanAction:(UIPanGestureRecognizer *)gesture {
 
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.rightPrePoint = [gesture locationInView:self];
            self.videoFrameTrackView.hidden = YES;
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self];
            // 偏移量X
            int offSetX = point.x - self.rightPrePoint.x;

            self.rightOverlayView.centerX += offSetX;
            
            CGFloat frameImageContainerW = (SCREEN_WIDTH - kMargin * 2);
            CGFloat onSectionFrameW = frameImageContainerW / 10;
            CGFloat maxRightMoveLenght = onSectionFrameW * 3 + kMargin;
            
            if (self.rightOverlayView.centerX - self.leftOverlayView.centerX - SCREEN_WIDTH <= 3 * onSectionFrameW) {
                self.rightOverlayView.centerX = self.leftOverlayView.centerX + SCREEN_WIDTH + 3 * onSectionFrameW;
            }
            
            // 右边滑块超过右滑的最大位置
            if ((SCREEN_WIDTH * 0.5 - kMargin + SCREEN_WIDTH) <= self.rightOverlayView.centerX) {
                self.rightOverlayView.centerX = SCREEN_WIDTH * 0.5 - kMargin + SCREEN_WIDTH;
            }

            // 右边滑块超过左滑的最大位置
            if (self.rightOverlayView.centerX <= (SCREEN_WIDTH * 0.5 + maxRightMoveLenght)) {
                self.rightOverlayView.centerX = (SCREEN_WIDTH * 0.5 + maxRightMoveLenght);
            }
            self.rightPrePoint = point;
            
            [self seekVideo];
            self.videoFrameTrackView.hidden = YES;
            break;
        }
        case UIGestureRecognizerStateEnded:
            self.videoFrameTrackView.hidden = NO;
            break;
        default:
            break;
    }
}
@end
