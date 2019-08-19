//
//  HHVideoCamera.m
//  HHCamera
//
//  Created by Hayder on 2018/10/5.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHVideoCamera.h"
#import "HHMicroPreviewView.h"
#import "HHCameraHelper.h"
#import "HHAVKitConfig.h"
#import "HHVideoCameraHelper.h"
#import "HHVideoEditFrameView.h"
#import "globalDefine.h"

@interface HHVideoCamera()<HHMicroPreviewViewDelegate>

/**工作圈小视频*/
@property (nonatomic, strong) NSTimer *workWorldTimer;
/**录制中的提示*/
@property (nonatomic, strong) UILabel *recordTipView;
/**工作圈记录时间*/
@property (nonatomic, assign) NSInteger recordCount;
/**定时器*/
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) HHCircleProgressView *circleProgress;
/**
 编辑视频
 */
@property (nonatomic, strong) HHVideoEditFrameView *editVideoView;

/**
 预览view
 */
@property (nonatomic, strong) HHMicroPreviewView *preview;

/**当前记录的时间*/
@property (nonatomic, assign) NSInteger currentRecordTime;

@end

@implementation HHVideoCamera

- (BOOL)isLegalOption
{
    return (self.option.type == SessionTypePhoto)?NO:YES;
}

- (instancetype)initWithFrame:(CGRect)frame Option:(HHAVKitOption *)option
{
    if (self = [super initWithFrame:frame Option:option]) {
        [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

//appk进入后台
- (void)applicationDidEnterBackground
{
    [self beginRecord:self.recordBtn];
}

- (void)addSubViews
{
    CGFloat selfHeight = self.frame.size.height;
    CGFloat selfWidth = self.frame.size.width;
    
    //录制按钮
    self.recordBtn = [[UIButton alloc] init];
    [self.recordBtn setFrame:CGRectMake(selfWidth/2 - 30, selfHeight * 3/4 + selfHeight * 1/4 / 2 - 30, 60, 60)];
    [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"record_normal"] forState:UIControlStateNormal];
    [self.recordBtn setBackgroundImage:[HHCameraHelper image:[UIImage imageNamed:@"record_normal"] WithTintColor:kCameraThemeColor] forState:UIControlStateSelected];
    [self.recordBtn addTarget:self action:@selector(beginRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.recordBtn];
    
    //取消按钮
    self.cancelBtn = [[UIButton alloc] init];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(onCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn.frame = CGRectMake(CGRectGetMinX(self.recordBtn.frame)-60-30, self.recordBtn.frame.origin.y, 60, 60);
    [self addSubview:self.cancelBtn];
    
    //录制提示
    self.recordTipView = [[UILabel alloc] init];
    self.recordTipView.backgroundColor = RGBA(255, 0, 0, 0.7);
    self.recordTipView.textColor = [UIColor whiteColor];
    self.recordTipView.textAlignment = NSTextAlignmentCenter;
    self.recordTipView.font = [UIFont systemFontOfSize:15.f];
    self.recordTipView.text = @"拍摄中";
    self.recordTipView.hidden = YES;
    self.recordTipView.frame = CGRectMake(20, 30, 80, 30);
    self.recordTipView.layer.cornerRadius = 3.f;
    self.recordTipView.layer.masksToBounds = YES;
    [self addSubview:self.recordTipView];
    
    CGFloat width = 100;
    CGFloat height = 100;
    self.circleProgress = [[HHCircleProgressView alloc] initWithFrame:CGRectMake((selfWidth - width)/2, (selfHeight - height)/2, width, height) progress:0 progressWidth:15];
    self.circleProgress.bottomColor = RGBA(255, 255, 255, 0.3);
    self.circleProgress.topColor = kCameraThemeColor;
    self.circleProgress.backgroundColor = [UIColor clearColor];
    self.circleProgress.progressLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",
                                              self.option.recordMaxTime/60, self.option.recordMaxTime%60];
    self.circleProgress.progressLabel.font = [UIFont systemFontOfSize:20.f];
    [self addSubview:self.circleProgress];
}

#pragma mark ---------------------HHMicroPreviewViewDelegate-----------------------------------------
- (void)microPreviewViewDidClickBackBtn:(HHMicroPreviewView *)microPreviewView {
    
    [microPreviewView stop];
    [microPreviewView removeFromSuperview];
    microPreviewView = nil;
}

- (void)microPreviewViewDidClickSureBtn:(HHMicroPreviewView *)microPreviewView
{
    [self didClickBtnWithURL:microPreviewView.filePath];
}

- (void)microPreviewViewDidClickEditBtn:(HHMicroPreviewView *)microPreviewView
{
    [self.preview stop];
    WS(weakSelf)
    self.editVideoView = [[HHVideoEditFrameView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.editVideoView.inputPath = [NSURL fileURLWithPath:microPreviewView.filePath];
    self.editVideoView.completeBlock = ^(NSURL *outputPath) {
        [weakSelf didClickBtnWithURL:outputPath.path];
    };
    self.editVideoView.cancelBlock = ^(HHVideoEditFrameView *videoEditFrameView) {
        [weakSelf.preview resume];
        [videoEditFrameView removeFromSuperview];
    };
    [microPreviewView addSubview:self.editVideoView];
}

- (void)didClickBtnWithURL:(NSString *)filePath
{
    //视频截图
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
    imageGenerator.appliesPreferredTrackTransform = YES;    // 截图的时候调整到正确的方向
    CMTime time = CMTimeMakeWithSeconds(1.0, 30);   // 1.0为截取视频1.0秒处的图片，30为每秒30帧
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:nil error:nil];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    if ([self.delegate respondsToSelector:@selector(microVideoPath:thumbImage:)]) {
        [self.delegate microVideoPath:filePath thumbImage:image];
    }
    
    if ([self.delegate respondsToSelector:@selector(microVideoPath:thumbImage:gifFaceURL:)]) {
        
        [[HHVideoCameraHelper getHelper] generateImagesWithVideoPath:filePath Completion:^(BOOL isSuccessed, NSString *imageURL) {
            [self.delegate microVideoPath:filePath thumbImage:image gifFaceURL:imageURL];
        }];
    }
    [self onCancelBtn:self.cancelBtn];
}
#pragma mark ---------------------delegate-----------------------------------------
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error
{
    //录制结束
    NSString *nsTmpDIr = NSTemporaryDirectory();
    NSString *videoPath = [NSString stringWithFormat:@"%@record_video_mp4_%3.f.%@", nsTmpDIr, [NSDate timeIntervalSinceReferenceDate], @"mp4"];
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:outputFileURL options:nil];
    __weak typeof(self) ws = self;
   
    [HHCameraHelper showWaitingDialogWithMsg:@"正在转码" container:self];
    [HHCameraHelper convertToMP4:self.option.qualityLevel avAsset:urlAsset videoPath:videoPath succ:^(NSString *resultPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [HHCameraHelper dismissWaitingDialogOnContainer:self];
            self.circleProgress.progress = 0;
            self.circleProgress.progressLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",
                                                      self.option.recordMaxTime/60, self.option.recordMaxTime%60];
            self.recordBtn.selected = NO;
            self.recordTipView.hidden = YES;
            //开始播放一遍
            ws.preview = [[HHMicroPreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            ws.preview.option = ws.option;
            ws.preview.filePath = resultPath;
            ws.preview.delegate = ws;
            ws.preview.currentTime = self.currentRecordTime;
            [ws addSubview:ws.preview];
            [ws.preview layoutBtns];
        });
    } fail:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [HHCameraHelper dismissWaitingDialogOnContainer:self];
            self.circleProgress.progress = 0;
            self.circleProgress.progressLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",
                                                      self.option.recordMaxTime/60, self.option.recordMaxTime%60];
            self.recordBtn.selected = NO;
            self.recordTipView.hidden = YES;
            [HHCameraHelper showMessage:@"转码失败" container:self];
        });
    }];
}

#pragma mark ---------------------private Func-----------------------------------------
- (void)addTimer
{
    self.workWorldTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(workWordRecordTimer:) userInfo:nil repeats:YES];
}

- (void)removeTimer
{
    self.recordCount = self.option.recordMaxTime;
    
    [self.workWorldTimer invalidate];
    self.workWorldTimer = nil;
}

- (void)workWordRecordTimer:(NSTimer *)timer
{
    self.recordCount --;
    
    _circleProgress.progressLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",
                                          self.recordCount/60, self.recordCount%60];
    if (self.recordCount ==0) {
        [self removeTimer];
        //调用录制结束的方法
        [self stopRecord];
        self.recordBtn.selected = NO;
    }
    
    _circleProgress.progress =  (self.option.recordMaxTime - self.recordCount)*1.0 / self.option.recordMaxTime;
    self.currentRecordTime = self.option.recordMaxTime - self.recordCount;
}

- (void)onCancelBtn:(UIButton *)sender
{
    [self stopRecord];
    [self removeTimer];
    [self quit];
    [self hideSelf];
}

#pragma mark --------------------------------
- (void)beginRecord:(UIButton *)button
{
    //最少录制2s钟
    button.enabled = NO;
    [self removeDelayTimer];
    [super addTimerWithTime:2];
    
    button.selected = !button.selected;
    self.recordTipView.hidden = !button.selected;
    if (button.selected) { //开始录制
        //当前录制时间
        self.currentRecordTime = 0;
        [self removeTimer];
        [self addTimer];
        [self startRecord];
    }else //结束录制
    {
        [self removeTimer];
        [self stopRecord];
        self.recordBtn.selected = NO;
    }
}

- (void)clickDelay
{
    self.recordBtn.enabled = YES;
    [self removeDelayTimer];
}

- (void)dealloc
{
    [self stopRecord];
    [self removeTimer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
