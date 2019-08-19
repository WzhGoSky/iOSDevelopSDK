//
//  ZHScanView.m
//  sasasas
//
//  Created by WZH on 16/3/8.
//  Copyright © 2016年 lyj. All rights reserved.
//


#define KScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define KScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define ScreenHight KScreenHeight
#define ScreenWidth KScreenWidth
/**
 *  二维码扫描框的大小 正方形
 */
#define ScanWidth self.codeAreaFrame.size.width

/**
 *  扫描框的摆放位置
 */
#define ScanY self.codeAreaFrame.origin.y

#import <AVFoundation/AVFoundation.h>
#import "HHCodeScaningView.h"
#import "globalDefine.h"

@interface HHCodeScaningView()<AVCaptureMetadataOutputObjectsDelegate>
{
    int _num;
    BOOL _upOrdown;
    NSTimer * _timer;
}

@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * preview;

@property (nonatomic, retain) UIImageView *line;
@property (nonatomic, weak) UIImageView *codeIV;
@property (nonatomic, weak) UILabel *promptLabel;

@property (nonatomic, assign) CGRect codeAreaFrame;

@property (nonatomic, strong) UIView* upView;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIView *downView;

@end

@implementation HHCodeScaningView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.codeAreaFrame = CGRectMake(0, ScreenHight * 0.25, 280, 280);
        [self setupSetting];
    }
    
    return self;
}

//扫描框的位置和大小
- (instancetype)initWithScanFrame:(CGRect)frame
{
    if (self = [super init]) {
        
        self.codeAreaFrame = frame;
        
        [self setupSetting];
    }
    return self;
}

- (void)setupSetting{
    UIImageView *codeIV = [[UIImageView alloc]init];
    codeIV.userInteractionEnabled = YES;
    codeIV.image = [UIImage imageNamed:@"code_scan.png"];
    [self addSubview:codeIV];
    self.codeIV = codeIV;
    
    UIImageView *line = [[UIImageView alloc] init];
    line.image = [[UIImage imageNamed:@"code_scan_1.png"] imageWithTintColor:[UIColor whiteColor]];
    [self addSubview:line];
    self.line = line;
    
    _upOrdown = NO;
    _num =0;
    
    [self initStartcScanningQrcord];
}

- (void)addCoverView
{
    [self.upView removeFromSuperview];
    [self.leftView removeFromSuperview];
    [self.rightView removeFromSuperview];
    [self.downView removeFromSuperview];
    //    最上部view
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,ScanY)];//80
    upView.alpha = 0.5;
    upView.backgroundColor = [UIColor blackColor];
    self.upView = upView;
    [self addSubview:self.upView];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(upView.frame),(ScreenWidth - ScanWidth)/2,ScreenHight - ScanY)];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
    self.leftView = leftView;
    [self addSubview:self.leftView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame)+ScanWidth, CGRectGetMaxY(upView.frame), (ScreenWidth - ScanWidth)/2, ScreenHight - ScanY)];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    self.rightView = rightView;
    [self addSubview:self.rightView];
    
    //底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame),  ScanY + ScanWidth , ScreenWidth-CGRectGetWidth(leftView.frame) * 2, ScreenHight -ScanY - ScanWidth)];
    downView.alpha = 0.5;
    downView.backgroundColor = [UIColor blackColor];
    self.downView = downView;
    [self addSubview:self.downView];
}

#pragma mark --------------------------publicFunc-----------------------------------------
+(instancetype)scanView
{
    HHCodeScaningView *scanView = [[HHCodeScaningView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    
    return scanView;
}

+(instancetype)scanViewWithFrame:(CGRect)frame
{
    HHCodeScaningView *scanView = [[HHCodeScaningView alloc] initWithFrame:frame];
    
    return scanView;
}


- (void)startScaning
{
    [_session startRunning];
    
    [self removeTimer];
    [self addTimer];
}

- (void)addTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(scanAnimation) userInfo:nil repeats:YES];
}

- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
}

/**停止扫描*/
- (void)stopScaning
{
    [_session stopRunning];
    [self removeTimer];
}

#pragma mark --------------------------privateFunc-----------------------------------------

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat codeIVh = ScanWidth;
    CGFloat codeIVw = codeIVh;
    CGFloat codeIVx = (ScreenWidth - codeIVw)/2;
    CGFloat codeIVy = ScanY;
    self.codeIV.frame = CGRectMake(codeIVx, codeIVy, codeIVw, codeIVh);
    
    CGFloat linex = codeIVx;
    CGFloat liney = codeIVy;
    CGFloat linew = codeIVw;
    CGFloat lineh = 3;
    self.line.frame = CGRectMake(linex, liney, linew, lineh);
    
}

//开始扫描二维码
-(void)initStartcScanningQrcord{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    if (_input == nil) {
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备不可用" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [self addSubview:aler];
        [aler show];
        return;
    }
    
    // Output
    _output = [[ AVCaptureMetadataOutput alloc ] init ];
    [ _output setMetadataObjectsDelegate : self queue : dispatch_get_main_queue ()];
    _output.rectOfInterest= CGRectMake(ScanY/ScreenHight,(ScreenWidth - ScanWidth)/(2*ScreenWidth),ScanWidth/ScreenHight, ScanWidth/ScreenWidth);
    /**
    rectOfInterest （0，0，1，1）按照比例来的
    （y/self.height,x/self.width,height/self.height,width/self.height）
     （y,x,h,w）至于为什么这样  苹果规定  - -！！！ 
     */
    // Session
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode 支持
    _output.metadataObjectTypes = @[AVMetadataObjectTypeUPCECode,
                                    AVMetadataObjectTypeCode39Code,
                                    AVMetadataObjectTypeCode39Mod43Code,
                                    AVMetadataObjectTypeEAN13Code,
                                    AVMetadataObjectTypeEAN8Code,
                                    AVMetadataObjectTypeCode93Code,
                                    AVMetadataObjectTypeCode128Code,
                                    AVMetadataObjectTypePDF417Code,
                                    AVMetadataObjectTypeQRCode,
                                    AVMetadataObjectTypeAztecCode,
                                    AVMetadataObjectTypeInterleaved2of5Code,
                                    AVMetadataObjectTypeITF14Code,
                                    AVMetadataObjectTypeDataMatrixCode];
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHight);
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill ;
    [self.layer insertSublayer:_preview atIndex:0];
    
    [self addCoverView];
}

#pragma mark - 扫描动画
-(void)scanAnimation
{
    if(_upOrdown == NO) {
        _num ++;
        _line.frame = CGRectMake((ScreenWidth - ScanWidth)/2, ScanY + 2*_num, ScanWidth, 3);
        if ((2*_num == ScanWidth )||(2*_num == ScanWidth-1)) {
            _upOrdown = YES;
        }
    }
    else {
        _num --;
        _line.frame = CGRectMake((ScreenWidth - ScanWidth)/2, ScanY+ScanWidth-2*_num, ScanWidth, 3);
        if(_num == 0) {
            _upOrdown = NO;
        }
    }
}

#pragma mark 输出
- ( void )captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:( NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count ] > 0)
    {
        // 停止扫描
        [self stopScaning];
        
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex : 0 ];
        stringValue = metadataObject.stringValue ;
    
        if (self.delegate) {
            [self.delegate codeScaningView:self DidFinishRefreshingWithResult:stringValue];
        }
    }
}

- (void)dealloc
{
    [self removeTimer];
}

@end
