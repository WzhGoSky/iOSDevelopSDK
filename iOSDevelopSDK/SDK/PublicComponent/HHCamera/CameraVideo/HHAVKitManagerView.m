//
//  HHVideoSessionView.m
//  HHCamera
//
//  Created by Hayder on 2018/10/4.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHAVKitManagerView.h"
#import "globalDefine.h"

@interface HHAVKitManagerView()
{
    AVCaptureSession            *_session;
    AVCaptureDevice             *_videoDevice;
    AVCaptureDevice             *_audioDevice;
    AVCaptureDeviceInput        *_videoInput;
    AVCaptureDeviceInput        *_audioInput;
    AVCaptureMovieFileOutput    *_movieOutput; //视频流输出
    AVCaptureStillImageOutput   *_imageOutput; //照片流输出
    AVCaptureVideoPreviewLayer  *_previewLayer;
    NSString *_savePath;
}
@end

@implementation HHAVKitManagerView

- (instancetype)initWithFrame:(CGRect)frame Option:(HHAVKitOption *)option
{
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0;
        self.backgroundColor = [UIColor blackColor];
        _option = option;
        
        if ([self isLegalOption]) {
            //1.获取权限
            [self getAuthorization];
        }else
        {
            NSLog(@"=====option不合法======");
        }
        
    }
    return self;
}

//添加界面上的元素
- (void)addSubViews
{
    
}

- (void)addReverCamera
{
    //图片如果是1080p就隐藏
    if (self.option.preset != SessionPresetHigh) {
        UIButton *reverCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        [reverCamera setBackgroundImage:[UIImage imageNamed:@"reverCamera"] forState:UIControlStateNormal];
        [reverCamera addTarget:self action:@selector(reverCameraEvent:) forControlEvents:UIControlEventTouchUpInside];
        reverCamera.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 43, StatusBar_Height, 33, 33);
        [self addSubview:reverCamera];
        self.reverCamera = reverCamera;
    }
}

- (void)startRecord
{
    if (_option.type == SessionTypeVideo) {
        self.reverCamera.hidden = YES;
        [_movieOutput startRecordingToOutputFileURL:[self outputCaches] recordingDelegate:self];
    }
}

- (void)stopRecord
{
    if (_option.type == SessionTypeVideo) {
        self.reverCamera.hidden = NO;
        [_movieOutput stopRecording];
    }
}

- (void)quit
{
    [_session stopRunning];
}

- (NSURL *)outputCaches
{
    NSString *tempDir = NSTemporaryDirectory();
    _savePath = [NSString stringWithFormat:@"%@%@", tempDir, @"record_video.MOV"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_savePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:_savePath error:nil];
    }
    return [NSURL fileURLWithPath:_savePath];
}

- (BOOL)isLegalOption
{
    return NO;
}

#pragma mark ---------------------clickTiemr-----------------------------------------
- (void)addTimerWithTime:(CGFloat)timeGap
{
    self.clickTimer = [NSTimer scheduledTimerWithTimeInterval:timeGap target:self selector:@selector(clickDelay) userInfo:nil repeats:YES];
}

- (void)removeDelayTimer
{
    [self.clickTimer invalidate];
    self.clickTimer = nil;
}

- (void)clickDelay
{

}

#pragma mark ---------------------reverCameraEvent-----------------------------------------
/**
 切换摄像头
 */
- (void)reverCameraEvent:(UIButton *)sender
{
    [self swapFrontAndBackCameras];
}
#pragma mark ---------------------AVCaptureFileOutputRecordingDelegate-----------------------------------------
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    
}

- (void)initialSession
{
    _session = [[AVCaptureSession alloc] init];
    
    AVCaptureSessionPreset sessionPreset = AVCaptureSessionPreset640x480;
    
    if (_option.type == SessionTypePhoto) { //照相机模式才能选择
        
        if (_option.preset == SessionPresetMedium) {
            sessionPreset = AVCaptureSessionPreset1280x720;
        }
        
        if (_option.preset == SessionPresetHigh) {
            sessionPreset = AVCaptureSessionPreset1920x1080;
        }
    }
    
    if ([_session canSetSessionPreset:sessionPreset])
    {
        [_session setSessionPreset:sessionPreset];
    }
    [_session beginConfiguration];
    
    [self addVideo];
    if (_option.type == SessionTypeVideo) {
        [self addAudio];
    }
    
    [self addPreviewLayer];
    
    [_session commitConfiguration];
    [_session startRunning];
}

//获取摄像头授权
- (void)getAuthorization
{
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
    {
        case AVAuthorizationStatusAuthorized:   //已授权
        {
            [self initialSession];
            //2.添加切换摄像头按钮
            [self addReverCamera];
            //3.添加子控件
            [self addSubViews];
        }
            break;
        case AVAuthorizationStatusNotDetermined://未授权
        {
            __weak HHAVKitManagerView *ws = self;
            //请求权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if(granted)
                     {
                         [ws initialSession];
                         //2.添加切换摄像头按钮
                         [ws addReverCamera];
                         //3.添加子控件
                         [ws addSubViews];
                     }
                     else
                     {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                         
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                         [alert show];
#pragma clang diagnostic pop
                         
                         [ws onCancelBtn];
                         return;
                     }
                 });
             }];
        }
            break;
        default:
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
#pragma clang diagnostic pop
            [self onCancelBtn];
            
        }
            break;
    }
}

- (void)onCancelBtn
{
    [_session stopRunning];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)addVideo
{
    _videoDevice = [self deviceWithMediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    
    [self addVideoInput];
    
    if (self.option.type == SessionTypePhoto) {//照片
        [self addImageOutput];
    }else
    {
        [self addMovieOutput];
    }
}

- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType position:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

- (void)addVideoInput
{
    if (!_videoDevice || !_session)
    {
        return;
    }
    
    NSError *error;
    
    // 视频输入对象
    // 根据输入设备初始化输入对象，用户获取输入数据
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&error];
    if (error)
    {
        return;
    }
    
    // 将视频输入对象添加到会话 (AVCaptureSession) 中
    if ([_session canAddInput:_videoInput])
    {
        [_session addInput:_videoInput];
    }
}

- (void)addImageOutput
{
    _imageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary
                                         alloc]
                                        initWithObjectsAndKeys:AVVideoCodecJPEG,
                                        AVVideoCodecKey, nil];
    [_imageOutput setOutputSettings:outputSettings];
    if ([_session canAddOutput:_imageOutput]) {
        [_session addOutput:_imageOutput];
    }
}

- (void)addMovieOutput
{
    if (!_session)
    {
        return;
    }
    // 拍摄视频输出对象
    // 初始化输出设备对象，用户获取输出数据
    _movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    if ([_session canAddOutput:_movieOutput])
    {
        [_session addOutput:_movieOutput];
        AVCaptureConnection *captureConnection = [_movieOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoStabilizationSupported])
        {
            if ([captureConnection respondsToSelector:@selector(setPreferredVideoStabilizationMode:)])
            {
                captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
        }
        captureConnection.videoScaleAndCropFactor = captureConnection.videoMaxScaleAndCropFactor;
    }
}

- (void)addAudio
{
    NSError *error;
    // 添加一个音频输入设备
    _audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //  音频输入对象
    _audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:_audioDevice error:&error];
    if (error)
    {
        return;
    }
    // 将音频输入对象添加到会话 (AVCaptureSession) 中
    if ([_session canAddInput:_audioInput])
    {
        [_session addInput:_audioInput];
    }
}

//创建预览层
- (void)addPreviewLayer
{
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _previewLayer.frame = self.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    if (self.option.type == SessionTypePhoto) {
        _previewLayer.connection.videoOrientation = [_imageOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation;
    }else
    {
        _previewLayer.connection.videoOrientation = [_movieOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation;
    }
    _previewLayer.position = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    
    CALayer *layer = self.layer;
    layer.masksToBounds = YES;
    self.layer.masksToBounds = YES;
    [layer addSublayer:_previewLayer];
}

//拍照
- (void)takePhotoCompletion:(void (^)(UIImage *image)) completion
{
    AVCaptureConnection *videoConnection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        return;
    }
    
    [_imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer,
                         NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        NSLog(@"image size = %@", NSStringFromCGSize(image.size));
        if (completion) {
            completion(image);
        }
    }];
}
#pragma mark ---------------------切换摄像头-----------------------------------------
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)swapFrontAndBackCameras {
    // Assume the session is already running
    
    NSArray *inputs =_session.inputs;
    for (AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera =nil;
            AVCaptureDeviceInput *newInput =nil;
            
            if (position ==AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [_session beginConfiguration];
            
            [_session removeInput:input];
            [_session addInput:newInput];
            // Changes take effect once the outermost commitConfiguration is invoked.
            [_session commitConfiguration];
            break;
        }
    }
}

//在什么上面展示
- (void)showOnContainer:(UIView *)container
{
    [container addSubview:self];
    [container bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
}

//隐藏
- (void)hideSelf
{
    [self onCancelBtn];
}

- (void)dealloc
{
    [self removeDelayTimer];
}

@end
