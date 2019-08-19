//
//  ImageShowDeitalView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/22.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "ImageShowDeitalView.h"
#import "PhotoScrollViewPlayerView.h"
#import "MicroPlayBottomView.h"
#import "ImageShowModel.h"
//#import <MBProgressHUD/MBProgressHUD.h>
#import "MBProgressHUD.h"
#import "ImageShowToolManager.h"
#import "ImageShowHelper.h"
#import "ImageShortVideoHandleView.h"
#import "ImageShortVideoInfoView.h"
#import "ImageShowConfigManager.h"
#import <YYImage/YYAnimatedImageView.h>
#import <YYImage/YYImage.h>
#import "globalDefine.h"
#import <SDWebImage/SDWebImage.h>
@interface ImageShowDeitalView()<AVPlayerManagerDelegate,MicroPlayBottomViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) YYAnimatedImageView *iconView;
@property (nonatomic, strong) UIView *playerContentView;
@property (nonatomic, strong) PhotoScrollViewPlayerView *playerView;
@property (nonatomic, strong) MicroPlayBottomView *setView;

@property (nonatomic, assign) CGFloat maximumZoomScale;

@property (nonatomic, assign) CGFloat minimumZoomScale;

@property (nonatomic, assign) AVPlayerPlayState playState;

@property (nonatomic, strong) UIView *tapView;

@end

@implementation ImageShowDeitalView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.maximumZoomScale = 2;
        self.minimumZoomScale = 1;
        self.backgroundColor = [UIColor clearColor];
        [self createTaps];
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.iconView];
        [self.scrollView addSubview:self.playerView];
        [self.scrollView addSubview:self.playerContentView];
        [self.playerContentView addSubview:self.setView];
        [self.scrollView addSubview:self.playBtn];
    }
    return self;
}

-(void)setModel:(ImageShowModel *)model{
    _model = model;
    
    self.playerView.hidden = !model.isVideo;
    self.setView.hidden = !model.isVideo;
    self.playBtn.hidden = !model.isVideo;
    self.iconView.hidden = NO;
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.setView.totalTime.text = @"00:00";
    
    if (model.img != nil) {
        self.iconView.image = model.img;
        [self refreshImgheightWithImg:model.img imageWitdth:model.img.size.width imageHeight: model.img.size.height];
    }else if (model.gifImg != nil){
        self.iconView.image = model.gifImg;
        [self.iconView autoPlayAnimatedImage];
        [self refreshImgheightWithImg:model.img imageWitdth:model.img.size.width imageHeight: model.img.size.height];
    }else{
        if (self.model.isOrigin) {//如果有原图
            NSString *urlStr =  model.originUrlStr;
            UIImage *image = [[UIImage alloc]initWithContentsOfFile:image_path(urlStr)];
            if (image) {//如果下载过原图
                model.img = image;
                self.iconView.image = image;
                [self refreshImgheightWithImg:image imageWitdth:image.size.width imageHeight: image.size.height];
                if (model.isOriginGif) {
                    [self.iconView autoPlayAnimatedImage];
                }
            }else{//如果没下载过原图
                
                NSString *temImgUrl = model.originUrlStr;
                if (model.originUrlStr) {
                    temImgUrl = [temImgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                
                if (model.isOriginGif) {
                    self.iconView.image = imageNamed(@"imgdefault");
                    [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:temImgUrl]options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL){
                    }completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                        if (finished) {
                            if (error) {
                            }else{
                                if (model.isOriginGif) {
                                    model.gifImg = [YYImage imageWithData:data];
                                    self.iconView.image = model.gifImg;
                                    [self.iconView autoPlayAnimatedImage];
                                    [self refreshImgheightWithImg:image imageWitdth:image.size.width imageHeight: image.size.height];
                                }else{
                                    model.img = image;
                                    self.iconView.image = image;
                                    [self refreshImgheightWithImg:image imageWitdth:image.size.width imageHeight: image.size.height];
                                }
                            }
                        }
                    }];
                }else{
                    
                    NSString *tempUrl = temImgUrl;
                    if ([tempUrl containsString:@"oss-cn"]) {
                        tempUrl = [NSString stringWithFormat:@"%@?x-oss-process=image/quality,q_50",tempUrl];
                    }
                    
                    [self.iconView sd_setImageWithURL:[NSURL URLWithString:tempUrl] placeholderImage:imageNamed(@"imgdefault") options:SDWebImageProgressiveLoad completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        model.img = image;
                        self.iconView.image = image;
                        [self refreshImgheightWithImg:image imageWitdth:image.size.width imageHeight: image.size.height];
                    }];
                }
            }
        } else {
            NSString *temImgUrl = model.imageUrlStr;
            if (model.imageUrlStr) {
                temImgUrl = [temImgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            if (model.isGif) {
                self.iconView.image = imageNamed(@"imgdefault");
                
                [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:[NSURL URLWithString:temImgUrl]options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                }completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    if (finished) {
                        if (error) {
                        }else{
                            if (model.isGif) {
                                model.gifImg = [YYImage imageWithData:data];
                                self.iconView.image = model.gifImg;
                                [self.iconView autoPlayAnimatedImage];
                                [self refreshImgheightWithImg:image imageWitdth:image.size.width imageHeight: image.size.height];
                            }else{
                                model.img = image;
                                self.iconView.image = image;
                                [self refreshImgheightWithImg:image imageWitdth:image.size.width imageHeight: image.size.height];
                            }
                        }
                    }
                }];
            }else{
                [self.iconView sd_setImageWithURL:[NSURL URLWithString:temImgUrl] placeholderImage:imageNamed(@"imgdefault") options:SDWebImageProgressiveLoad completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    model.img = image;
                    self.iconView.image = image;
                    [self refreshImgheightWithImg:image imageWitdth:image.size.width imageHeight: image.size.height];
                }];
            }
        }
    }

    if (model.isVideo) {
        self.setView.startButton.selected = YES;
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self tapView];
    }else{
        [self.tapView removeFromSuperview];
    }
}


-(void)refreshImgheightWithImg:(UIImage *)image imageWitdth:(CGFloat)imgW imageHeight:(CGFloat)imgH{

    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat height = [[UIScreen mainScreen] bounds].size.width * imgH /  imgW;
        
        if (height >= self.scrollView.frame.size.height) {
            if (height >= self.scrollView.frame.size.height + 2) {
                self.iconView.contentMode = UIViewContentModeScaleAspectFill;
                
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, height);
            }else{
                
                self.iconView.contentMode = UIViewContentModeScaleAspectFit;
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
            }
            
        }else{
            self.iconView.contentMode = UIViewContentModeScaleAspectFit;
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, height);
            height = self.scrollView.frame.size.height;
        }
        
        self.iconView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height);
    
        CGFloat imgH = 200;
        if (image) {
            imgH = [[UIScreen mainScreen] bounds].size.width * image.size.height /  image.size.width;
        }
        self.tapView.frame = CGRectMake(0, (self.frame.size.height - imgH) * 0.5, self.frame.size.width, imgH);
        if (height > self.scrollView.frame.size.height && !self.model.isVideo) {
            [self.tapView removeFromSuperview];
        }else{
            [self tapView];
        }
        [self setNeedsLayout];
    });
}

#pragma AVPlayerManagerDelegate
//播放状态变更
- (void)AVPlayerPlayStatusChange:(AVPlayerPlayState)status{
    self.playState = status;
    [self refreshPlayViewState];
    
    switch (status) {
        case AVPlayerPlayStatePreparing:// 准备播放
        {
            NSLog(@"====准备播放====");
            self.setView.totalTime.text = [NSString stringWithFormat:@"%02d:%02d",
                                           (int)self.playerView.duration/60,(int)self.playerView.duration%60];
        }
            break;
        case AVPlayerPlayStateStart:// 开始播放
        {
            NSLog(@"====开始播放====");
        }
            break;
        case AVPlayerPlayStatePause:// 播放暂停
        {
            NSLog(@"====播放暂停====");
        }
            break;
        case AVPlayerPlayStatePlaying:// 正在播放
        {
            NSLog(@"====正在播放====");
        }
            break;
        case AVPlayerPlayStateEnd:// 播放结束
        {
            NSLog(@"====播放结束====");
            if ([self.delegate respondsToSelector:@selector(ImageShowDeitalViewDidPlayEnd:playTime:)]) {
                [self.delegate ImageShowDeitalViewDidPlayEnd:self.model playTime:self.playerView.duration];
            }
        }
            break;
        case AVPlayerPlayStateBufferEmpty:// 没有缓存的数据供播放了 需要时间加载
        {
            [self toastMessage:@"加载中.."];
        }
            break;
        case AVPlayerPlayStateNotPlay: // 不能播放
        {
            NSLog(@"====不能播放====");
            [self toastMessage:@"该视频无法播放!"];
        }
            break;
        case AVPlayerPlayStateNotKnow:// 未知情况
        {
            [self toastMessage:@"该视频无法播放!"];
        }
            break;
        default:
            break;
    }
}
//播放进度
- (void)AVPlayerDidProgress:(NSTimeInterval)value{
    //设置进度条
    CGFloat progress = value / self.playerView.duration;
    self.setView.seekProgress.value = progress;
    
    //更新时间
    self.setView.currentTime.text = [NSString stringWithFormat:@"%02d:%02d",
                                     (int)value/60,(int)value%60];
}

//缓冲进度
- (void)AVPlayerDidBufferProgress:(NSTimeInterval)value{

}

//点击视屏
- (void)AVPlayerDidClick{
//    [self play:self.playBtn];
}

#pragma MicroPlayBottomViewDelegate
/**
 slider滑动代理
 */
- (void)bottomBarSliderTouchDown:(MicroPlayBottomView *)bottomBar{
//    [self play:self.playBtn];
    [self.playerView pause];
}

/**
 slider滑动代理
 */
- (void)bottomBarSliderTouchUpInside:(MicroPlayBottomView *)bottomBar{
//    [self play:self.playBtn];
     [self.playerView play];
}

/**
 slider滑动代理
 */
- (void)bottomBar:(MicroPlayBottomView *)bottomBar sliderChanged:(float) value{
    self.playerView.initialPlaybackTime = self.playerView.duration * value;
    NSTimeInterval valueP = value * self.playerView.duration;
    bottomBar.currentTime.text = [NSString stringWithFormat:@"%02d:%02d",
                                  (int)valueP/60,(int)valueP%60];
}

/**
 状态栏点击了开关按钮
 */
- (void)bottomBarDidClickSwitchButton:(UIButton *)button{
    [self play:self.playBtn];
}

#pragma UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.iconView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect frame = self.iconView.frame;
    frame.origin.y = (self.scrollView.frame.size.height - self.iconView.frame.size.height) > 0 ? (self.scrollView.frame.size.height - self.iconView.frame.size.height) * 0.5 : 0;
    frame.origin.x = (self.scrollView.frame.size.width - self.iconView.frame.size.width) > 0 ? (self.scrollView.frame.size.width - self.iconView.frame.size.width) * 0.5 : 0;
    self.iconView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(self.iconView.frame.size.width, self.iconView.frame.size.height);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (!scrollView.showsVerticalScrollIndicator) {
        scrollView.showsVerticalScrollIndicator = YES;
    }
    if ((scrollView.contentOffset.y < 0 || (scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height) && [self.delegate respondsToSelector:@selector(ImageShowDeitalViewLongPictureWillDismissTransformY:scale:)]) {
        CGFloat transformY = 0;
        CGFloat scale = 0;
        if (scrollView.contentOffset.y < 0) {
            transformY = - scrollView.contentOffset.y;
            scale = (- scrollView.contentOffset.y / scrollView.frame.size.height);
        }else if ((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height){
            transformY = scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.frame.size.height);
            scale = ((scrollView.contentOffset.y + scrollView.frame.size.height) - scrollView.contentSize.height ) / scrollView.frame.size.height;
        }
        [self.delegate ImageShowDeitalViewLongPictureWillDismissTransformY:transformY scale:scale];
    }
}

#pragma private action
/**
 播放
 */
-(void)tapAction:(UITapGestureRecognizer *)tap{
    
    if (tap.view == self) {
        if ([self.delegate respondsToSelector:@selector(ImageShowDeitalViewDidDismiss)]) {
            [self.delegate ImageShowDeitalViewDidDismiss];
        }
    }else if (tap.view == self.tapView){
        if (self.model.isVideo) {
            [self play:self.playBtn];
        }else{
            if ([self.delegate respondsToSelector:@selector(ImageShowDeitalViewDidDismiss)]) {
                [self.delegate ImageShowDeitalViewDidDismiss];
            }
        }
    }
    
}

/**
 长按操作
 */
-(void)alertClick:(UILongPressGestureRecognizer *)tap{
    
    CGPoint point = [tap locationInView:self];
    if (CGRectContainsPoint(self.setView.frame, point)) {return;}
    
    if (tap.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(ImageShowDeitalViewDidAlertWithModel:)]) {
            [self.delegate ImageShowDeitalViewDidAlertWithModel:self.model];
        }
    }
}

/**
 播放、暂停
 */
-(void)play:(UIButton *)btn{
    BOOL isPlaying = self.playState == AVPlayerPlayStatePlaying || self.playState == AVPlayerPlayStateBufferToKeepUp;
    if (isPlaying) {
        [self.playerView pause];
    }else{
        if (self.playState == AVPlayerPlayStateBufferEmpty || self.playState == AVPlayerPlayStatePreparing || self.playState == AVPlayerPlayStateEnd) {
            if (self.model.viodeUrlStr ) {
//                [self.playerView setPlayUrl: [self.model.viodeUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [self.playerView setPlayUrl:self.model.viodeUrlStr];
            }
        }
        self.iconView.hidden = YES;
        [self.playerView play];
    }
}

/**
 返回
 */
-(void)backDidClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(ImageShowDeitalViewDidClickBack)]) {
        [self.delegate ImageShowDeitalViewDidClickBack];
    }
}

/**
 查看原图原图
 */
-(void)originalImg:(UIButton *)btn{
}


/**
 查看原图
 */
-(void)showOriginalImage{
    
}

-(void)touchChangingInSetView{
    
}

-(void)createTaps{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *tpall = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(alertClick:)];
    tpall.delegate = self;
    [self addGestureRecognizer:tpall];
    
    self.userInteractionEnabled = YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

-(void)refreshPlayViewState{
    
    if (!self.model.isVideo) {return;}

    BOOL isPlaying = self.playState == AVPlayerPlayStatePlaying || self.playState == AVPlayerPlayStateBufferToKeepUp || self.playState == AVPlayerPlayStateStart || self.playState == AVPlayerPlayStatePreparing;
    
    NSInteger playAlpha = isPlaying ? 1 : 0;
    
    self.playBtn.selected = !isPlaying;
    self.setView.startButton.selected = !isPlaying;
    
    self.playBtn.alpha = playAlpha;
    [UIView animateWithDuration:0.2 animations:^{
        self.playBtn.alpha = (1 - playAlpha);
    } completion:^(BOOL finished) {
        self.playBtn.alpha = (1 - playAlpha);
        self.playBtn.hidden = isPlaying;
    }];
    
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
}

#pragma lazy
-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _scrollView.maximumZoomScale = self.maximumZoomScale;
        _scrollView.minimumZoomScale = self.minimumZoomScale;
        _scrollView.userInteractionEnabled = YES;
        [_scrollView setZoomScale:1.0];
    }
    return _scrollView;
}
-(UIButton *)playBtn{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.selected = YES;
        [_playBtn setImage:imageNamed(@"play") forState:UIControlStateSelected];
        [_playBtn setImage:imageNamed(@"pause") forState:UIControlStateNormal];
        _playBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 100) * 0.5, ([UIScreen mainScreen].bounds.size.height - 100) * 0.5, 100, 100);
        [_playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

-(YYAnimatedImageView *)iconView{
    if (!_iconView) {
        _iconView = [[YYAnimatedImageView alloc]initWithFrame:self.bounds];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.image = imageNamed(@"imgdefault");
        _iconView.userInteractionEnabled = YES;
    }
    return _iconView;
}

-(PhotoScrollViewPlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[PhotoScrollViewPlayerView alloc]init];
        _playerView.frame = self.bounds;
        _playerView.hidden = YES;
        _playerView.delegate = self;
    }
    return _playerView;
}

-(UIView *)playerContentView{
    if (!_playerContentView) {
        _playerContentView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 60, [UIScreen mainScreen].bounds.size.width, 60)];
        _playerContentView.backgroundColor = [UIColor clearColor];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(touchChangingInSetView)];
        [_playerContentView addGestureRecognizer:pan];
    }
    return _playerContentView;
}


-(MicroPlayBottomView *)setView{
    if (!_setView) {
        _setView = [MicroPlayBottomView bottomView];
        _setView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        _setView.delegate = self;
        _setView.startButton.selected = NO;
    }
    return _setView;
}

-(UIView *)tapView{
    if (!_tapView) {
        _tapView = [[UIView alloc]initWithFrame:self.bounds];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tap.delegate = self;
        tap.numberOfTapsRequired = 1;
        [_tapView addGestureRecognizer:tap];
        [self addSubview:_tapView];
    }
    return _tapView;
}


@end


@interface ImageShowDeitalViewCell()

@property (nonatomic, strong) ImageShowDeitalView *mainView;

@end

@implementation ImageShowDeitalViewCell
/**
 查看原图
 */
-(void)showOriginalImage{
    [self.mainView showOriginalImage];
}

-(void)hiddenLongVerticalView:(BOOL)isShow{
    self.mainView.scrollView.showsVerticalScrollIndicator = isShow;
}

-(void)hiddenSetView{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.mainView.setView.alpha = 0;
    } completion:^(BOOL finished) {
        self.mainView.setView.alpha = 1;
        self.mainView.setView.hidden = YES;
    }];
}

-(void)showSetView{
    self.mainView.setView.alpha = 0;
    self.mainView.setView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.mainView.setView.alpha = 1;
    } completion:^(BOOL finished) {
        self.mainView.setView.hidden = NO;
    }];
}


-(void)setModel:(ImageShowModel *)model{
    _model = model;
    self.mainView.model = model;
}

-(void)setDelegate:(id<ImageShowDeitalViewDelegate>)delegate{
    _delegate = delegate;
    self.mainView.delegate = delegate;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.mainView.frame = self.bounds;
}

-(ImageShowDeitalView *)mainView{
    if (!_mainView) {
        _mainView = [[ImageShowDeitalView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:_mainView];
    }
    return _mainView;
}

-(void)pause{
    if (self.mainView.model.isVideo && self.mainView.playerView.isPlaying) {
        
        if (self.mainView.playerView.isPlaying) {
            self.model.currentPlayTime = self.mainView.playerView.currentPlayTime;
            [self.mainView.playerView pause];
        }
    }
}

-(void)play{
    if (self.mainView.model.isVideo && !self.mainView.playerView.isPlaying) {
        if (self.model.viodeUrlStr && self.model.currentPlayTime == 0) {
//            [self.mainView.playerView setPlayUrl: [self.model.viodeUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [self.mainView.playerView setPlayUrl: self.model.viodeUrlStr];
        }
        if (self.model.currentPlayTime != self.mainView.playerView.duration || (self.model.currentPlayTime == 0 && self.mainView.playerView.duration == 0)) {
            self.mainView.playerView.initialPlaybackTime = self.model.currentPlayTime;
            self.mainView.setView.seekProgress.value = self.model.currentPlayTime / self.mainView.playerView.duration;
            self.mainView.setView.currentTime.text = [NSString stringWithFormat:@"%02d:%02d",
                                                      (int)self.model.currentPlayTime/60,(int)self.model.currentPlayTime%60];
            self.mainView.setView.totalTime.text = [NSString stringWithFormat:@"%02d:%02d",
                                                    (int)self.mainView.playerView.duration/60,(int)self.mainView.playerView.duration%60];
            [self.mainView.playerView play];
            self.mainView.iconView.hidden = YES;
        }
    }
}

-(void)setOriginalBtnTransFromY:(CGFloat)originalBtnTransFromY{
    _originalBtnTransFromY = originalBtnTransFromY;
    if (originalBtnTransFromY == 0) {
        self.mainView.playerContentView.transform = CGAffineTransformIdentity;
    }else{
        self.mainView.playerContentView.transform = CGAffineTransformMakeTranslation(0, - originalBtnTransFromY);
    }
}

-(void)setDownLoadImg:(UIImage *)downLoadImg{
    _downLoadImg = downLoadImg;
    
    if ([downLoadImg isKindOfClass:[YYImage class]]) {
        self.mainView.iconView.image = downLoadImg;
        [self.mainView.iconView autoPlayAnimatedImage];
    }else{
        self.mainView.iconView.image = downLoadImg;
    }
}

@end



@interface ShortVideoViewCell()<ImageShortVideoInfoViewDelegate,ShoreVideoHandleDelegate>

@property (nonatomic, strong) ImageShortVideoHandleView *shortVideoHandleView;

@property (nonatomic, strong) ImageShortVideoInfoView *shotVideoInfoView;

@end

@implementation ShortVideoViewCell

-(void)ImageShowDeitalViewDidDismiss:(BOOL)isShow{
        if (isShow) {
            [UIView animateWithDuration:0.5 animations:^{
                self.shotVideoInfoView.transform = CGAffineTransformMakeTranslation(0, self.shotVideoInfoView.frame.size.height + 10);
                self.shortVideoHandleView.transform = CGAffineTransformMakeTranslation(self.shortVideoHandleView.frame.size.width, 0);
            } completion:^(BOOL finished) {
                self.mainView.setView.hidden = NO;
            }];
        }else{
            
            self.mainView.setView.hidden = YES;
            [UIView animateWithDuration:0.5 animations:^{
                self.shotVideoInfoView.transform = CGAffineTransformIdentity;
                self.shortVideoHandleView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
            }];
        }
}

static CGFloat handleWH = 50;

-(void)setShortVideoType:(ShowShortVideoMangerType)shortVideoType{
    _shortVideoType = shortVideoType;
    
    self.mainView.setView.hidden = YES;
    
    self.layer.masksToBounds = YES;
    [self.contentView addSubview:self.shortVideoHandleView];
    [self.contentView addSubview:self.shotVideoInfoView];
}

-(void)setModel:(ImageShowModel *)model{
    [super setModel:model];
    
    self.mainView.setView.hidden = YES;
    self.shotVideoInfoView.model = model;
}

-(void)ShortVideoLike{
    if ([self.delegate respondsToSelector:@selector(ShortVideoViewCellDidLike)]) {
        [self.delegate ShortVideoViewCellDidLike];
    }
}

-(void)ShortVideoComment{
    if ([self.delegate respondsToSelector:@selector(ShortVideoViewCellDidComment)]) {
        [self.delegate ShortVideoViewCellDidComment];
    }
}

-(void)ShortVideoShare{
    if ([self.delegate respondsToSelector:@selector(ShortVideoViewCellDidShare)]) {
        [self.delegate ShortVideoViewCellDidShare];
    }
}

-(void)ShortVideoDownLoad{
    if ([self.delegate respondsToSelector:@selector(ShortVideoViewCellDidDownLoad)]) {
        [self.delegate ShortVideoViewCellDidDownLoad];
    }
}

-(void)ImageShortVideoInfoViewDidClickUserheader:(ImageShowModel *)mode{
    if ([self.delegate respondsToSelector:@selector(ShortVideoViewDidClickUserHeader)]) {
        [self.delegate ShortVideoViewDidClickUserHeader];
    }
}

-(ImageShortVideoHandleView *)shortVideoHandleView{
    if (!_shortVideoHandleView) {
        NSMutableArray *items = [[ImageShowConfigManager shareInstance] getShortVideoHandleWithType:self.shortVideoType delegaate:self];
        CGFloat height = items.count * (handleWH + 10);
        _shortVideoHandleView  = [ImageShortVideoHandleView handleActionViewWithModels:items frame:CGRectMake(self.bounds.size.width - handleWH, self.bounds.size.height - 150 - 10 - height, handleWH,height)];
    }
    return _shortVideoHandleView;
}

-(ImageShortVideoInfoView *)shotVideoInfoView{
    if (!_shotVideoInfoView) {
        _shotVideoInfoView = [[ImageShortVideoInfoView alloc]initWithFrame:CGRectMake(15, self.frame.size.height - 10 - 150, self.frame.size.width - 30, 150)];
        _shotVideoInfoView.delegate = self;
    }
    return _shotVideoInfoView;
}
@end
