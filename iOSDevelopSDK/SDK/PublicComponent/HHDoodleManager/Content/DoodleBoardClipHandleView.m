//
//  DoodleBoardClipHandleView.m
//  AFNetworking
//
//  Created by Hayder on 2019/4/12.
//

#import "DoodleBoardClipHandleView.h"
#import "DoodleBoardClipAreaLayer.h"
#import "DoodleBoardPanGestureRecognizer.h"

#import "globalDefine.h"

@interface DoodleBoardClipHandleBottomView()
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *titleLabel;
@property (nonatomic, strong) UIButton *finishBtn;
@end

@implementation DoodleBoardClipHandleBottomView


-(instancetype)init{
    self = [super init];
    if (self) {
        [self addSubview:self.closeBtn];
        [self addSubview:self.finishBtn];
//        [self addSubview:self.titleLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.closeBtn.frame = CGRectMake(0, 0, 100, self.frame.size.height);
    self.finishBtn.frame = CGRectMake(self.frame.size.width - 100, 0, 100, self.frame.size.height);
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.closeBtn.frame), 0, self.frame.size.width - 200, self.frame.size.height);
}

-(void)didClickClose:(UIButton *)btn{
    !self.didClickCloseBlock?:self.didClickCloseBlock();
}

-(void)didClickFinfish:(UIButton *)btn{
    !self.didClickFinishBlock?:self.didClickFinishBlock();
}

-(void)didClickTitle:(UIButton *)btn{
    !self.didClickTitleBlock?:self.didClickTitleBlock();
}

-(UIButton *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UIButton alloc]init];
        [_titleLabel setTitle:@"还原" forState:UIControlStateNormal];
        [_titleLabel setTitle:@"还原" forState:UIControlStateSelected];
        [_titleLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_titleLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _titleLabel.titleLabel.font = [UIFont systemFontOfSize:16];
        [_titleLabel addTarget:self action:@selector(didClickTitle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _titleLabel;
}


-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"doodleClipClose"] forState:UIControlStateNormal];
        [_closeBtn setImage:[UIImage imageNamed:@"doodleClipClose"] forState:UIControlStateSelected];
        [_closeBtn addTarget:self action:@selector(didClickClose:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

-(UIButton *)finishBtn{
    if (!_finishBtn) {
        _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_finishBtn setImage:[UIImage imageNamed:@"doodleClipFinish"] forState:UIControlStateNormal];
        [_finishBtn setImage:[UIImage imageNamed:@"doodleClipFinish"] forState:UIControlStateSelected];
        [_finishBtn addTarget:self action:@selector(didClickFinfish:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishBtn;
}


@end


typedef NS_ENUM(NSInteger, ACTIVEGESTUREVIEW) {
    CROPVIEWLEFT,
    CROPVIEWRIGHT,
    CROPVIEWTOP,
    CROPVIEWBOTTOM,
    BIGIMAGEVIEW
};

@interface DoodleBoardClipHandleView()

@property (strong, nonatomic) UIImage *targetImage;
@property(strong, nonatomic) UIImageView *bigImageView;
@property(strong, nonatomic) UIView *cropView;

@property(assign, nonatomic) ACTIVEGESTUREVIEW activeGestureView;

// 图片 view 原始 frame
@property(assign, nonatomic) CGRect originalFrame;

// 裁剪区域属性
@property(assign, nonatomic) CGFloat cropAreaX;
@property(assign, nonatomic) CGFloat cropAreaY;
@property(assign, nonatomic) CGFloat cropAreaWidth;
@property(assign, nonatomic) CGFloat cropAreaHeight;

@property(nonatomic, assign) CGFloat clipHeight;
@property(nonatomic, assign) CGFloat clipWidth;

@property (nonatomic, strong) DoodleBoardClipConfigModel *frameConfig;

@end

@implementation DoodleBoardClipHandleView


-(void)setFrameConfig:(DoodleBoardClipConfigModel *)frameConfig
{
    _frameConfig = frameConfig;
    
    self.cropAreaY += frameConfig.top;//修改上边距
    self.cropAreaHeight -= frameConfig.top;
    
    self.cropAreaX +=  frameConfig.left;//修改左边距
    self.cropAreaWidth -= frameConfig.top;
    
    self.cropAreaHeight -= frameConfig.bottom;//修改下边距
    self.cropAreaWidth -=  frameConfig.right;//修改右边距
    
    [self setUpCropLayer];
}


-(instancetype)initWithFrame:(CGRect)frame img:(UIImage *)img{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.targetImage = img;
        [self addSubview:self.cropView];
        [self addSubview:self.bigImageView];
        
        self.clipWidth = self.frame.size.width;
        self.clipHeight = self.clipWidth * 9/16;
        
        self.cropAreaX = (self.frame.size.width - self.clipWidth)/2;
        self.cropAreaY = (self.frame.size.height - self.clipHeight)/2;
        self.cropAreaWidth = self.clipWidth;
        self.cropAreaHeight = self.clipHeight;
        
        self.bigImageView.image = self.targetImage;
        [self addAllGesture];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setUpCropLayer];
        });
    }
    return self;
}

-(void)addAllGesture
{
    // 捏合手势
    UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterPinGesture:)];
    [self addGestureRecognizer:pinGesture];
    
    // 拖动手势
    DoodleBoardPanGestureRecognizer *panGesture = [[DoodleBoardPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDynamicPanGesture:) inview:self.cropView];
    [self.cropView addGestureRecognizer:panGesture];
}

-(void)handleDynamicPanGesture:(DoodleBoardPanGestureRecognizer *)panGesture
{
    UIView * view = self.bigImageView;
    CGPoint translation = [panGesture translationInView:view.superview];
    
    CGPoint beginPoint = panGesture.beginPoint;
    CGPoint movePoint = panGesture.movePoint;
    CGFloat judgeWidth = 20;
    
    // 开始滑动时判断滑动对象是 ImageView 还是 Layer 上的 Line
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (beginPoint.x >= self.cropAreaX - judgeWidth && beginPoint.x <= self.cropAreaX + judgeWidth && beginPoint.y >= self.cropAreaY && beginPoint.y <= self.cropAreaY + self.cropAreaHeight && self.cropAreaWidth >= 50) {
            self.activeGestureView = CROPVIEWLEFT;
        } else if (beginPoint.x >= self.cropAreaX + self.cropAreaWidth - judgeWidth && beginPoint.x <= self.cropAreaX + self.cropAreaWidth + judgeWidth && beginPoint.y >= self.cropAreaY && beginPoint.y <= self.cropAreaY + self.cropAreaHeight &&  self.cropAreaWidth >= 50) {
            self.activeGestureView = CROPVIEWRIGHT;
        } else if (beginPoint.y >= self.cropAreaY - judgeWidth && beginPoint.y <= self.cropAreaY + judgeWidth && beginPoint.x >= self.cropAreaX && beginPoint.x <= self.cropAreaX + self.cropAreaWidth && self.cropAreaHeight >= 50) {
            self.activeGestureView = CROPVIEWTOP;
        } else if (beginPoint.y >= self.cropAreaY + self.cropAreaHeight - judgeWidth && beginPoint.y <= self.cropAreaY + self.cropAreaHeight + judgeWidth && beginPoint.x >= self.cropAreaX && beginPoint.x <= self.cropAreaX + self.cropAreaWidth && self.cropAreaHeight >= 50) {
            self.activeGestureView = CROPVIEWBOTTOM;
        } else {
            self.activeGestureView = BIGIMAGEVIEW;
            [view setCenter:CGPointMake(view.center.x + translation.x, view.center.y + translation.y)];
            [panGesture setTranslation:CGPointZero inView:view.superview];
        }
    }
    
    // 滑动过程中进行位置改变
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat diff = 0;
        switch (self.activeGestureView) {
            case CROPVIEWLEFT: {
                diff = movePoint.x - self.cropAreaX;
                if (diff >= 0 && self.cropAreaWidth > 50) {
                    self.cropAreaWidth -= diff;
                    self.cropAreaX += diff;
                } else if (diff < 0 && self.cropAreaX > self.bigImageView.frame.origin.x && self.cropAreaX >= 15) {
                    self.cropAreaWidth -= diff;
                    self.cropAreaX += diff;
                }
                [self setUpCropLayer];
                break;
            }
            case CROPVIEWRIGHT: {
                diff = movePoint.x - self.cropAreaX - self.cropAreaWidth;
                if (diff >= 0 && (self.cropAreaX + self.cropAreaWidth) < MIN(self.bigImageView.frame.origin.x + self.bigImageView.frame.size.width, self.cropView.frame.origin.x + self.cropView.frame.size.width - 15)){
                    self.cropAreaWidth += diff;
                } else if (diff < 0 && self.cropAreaWidth >= 50) {
                    self.cropAreaWidth += diff;
                }
                [self setUpCropLayer];
                break;
            }
            case CROPVIEWTOP: {
                diff = movePoint.y - self.cropAreaY;
                if (diff >= 0 && self.cropAreaHeight > 50) {
                    self.cropAreaHeight -= diff;
                    self.cropAreaY += diff;
                } else if (diff < 0 && self.cropAreaY > self.bigImageView.frame.origin.y && self.cropAreaY >= 15) {
                    self.cropAreaHeight -= diff;
                    self.cropAreaY += diff;
                }
                [self setUpCropLayer];
                break;
            }
            case CROPVIEWBOTTOM: {
                diff = movePoint.y - self.cropAreaY - self.cropAreaHeight;
                if (diff >= 0 && (self.cropAreaY + self.cropAreaHeight) < MIN(self.bigImageView.frame.origin.y + self.bigImageView.frame.size.height, self.cropView.frame.origin.y + self.cropView.frame.size.height - 15)){
                    self.cropAreaHeight += diff;
                } else if (diff < 0 && self.cropAreaHeight >= 50) {
                    self.cropAreaHeight += diff;
                }
                [self setUpCropLayer];
                break;
            }
            case BIGIMAGEVIEW: {
                [view setCenter:CGPointMake(view.center.x + translation.x, view.center.y + translation.y)];
                [panGesture setTranslation:CGPointZero inView:view.superview];
                break;
            }
            default:
                break;
        }
    }
    
    // 滑动结束后进行位置修正
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        switch (self.activeGestureView) {
            case CROPVIEWLEFT: {
                if (self.cropAreaWidth < 50) {
                    self.cropAreaX -= 50 - self.cropAreaWidth;
                    self.cropAreaWidth = 50;
                }
                if (self.cropAreaX < MAX(self.bigImageView.frame.origin.x, 15)) {
                    CGFloat temp = self.cropAreaX + self.cropAreaWidth;
                    self.cropAreaX = MAX(self.bigImageView.frame.origin.x, 15);
                    self.cropAreaWidth = temp - self.cropAreaX;
                }
                [self setUpCropLayer];
                break;
            }
            case CROPVIEWRIGHT: {
                if (self.cropAreaWidth < 50) {
                    self.cropAreaWidth = 50;
                }
                if (self.cropAreaX + self.cropAreaWidth > MIN(self.bigImageView.frame.origin.x + self.bigImageView.frame.size.width, self.cropView.frame.origin.x + self.cropView.frame.size.width - 15)) {
                    self.cropAreaWidth = MIN(self.bigImageView.frame.origin.x + self.bigImageView.frame.size.width, self.cropView.frame.origin.x + self.cropView.frame.size.width - 15) - self.cropAreaX;
                }
                [self setUpCropLayer];
                break;
            }
            case CROPVIEWTOP: {
                if (self.cropAreaHeight < 50) {
                    self.cropAreaY -= 50 - self.cropAreaHeight;
                    self.cropAreaHeight = 50;
                }
                if (self.cropAreaY < MAX(self.bigImageView.frame.origin.y, 15)) {
                    CGFloat temp = self.cropAreaY + self.cropAreaHeight;
                    self.cropAreaY = MAX(self.bigImageView.frame.origin.y, 15);
                    self.cropAreaHeight = temp - self.cropAreaY;
                }
                [self setUpCropLayer];
                break;
            }
            case CROPVIEWBOTTOM: {
                if (self.cropAreaHeight < 50) {
                    self.cropAreaHeight = 50;
                }
                if (self.cropAreaY + self.cropAreaHeight > MIN(self.bigImageView.frame.origin.y + self.bigImageView.frame.size.height, self.cropView.frame.origin.y + self.cropView.frame.size.height - 15)) {
                    self.cropAreaHeight = MIN(self.bigImageView.frame.origin.y + self.bigImageView.frame.size.height, self.cropView.frame.origin.y + self.cropView.frame.size.height - 15) - self.cropAreaY;
                }
                [self setUpCropLayer];
                break;
            }
            case BIGIMAGEVIEW: {
                CGRect currentFrame = view.frame;
                
                if (currentFrame.origin.x >= self.cropAreaX) {
                    currentFrame.origin.x = self.cropAreaX;
                    
                }
                if (currentFrame.origin.y >= self.cropAreaY) {
                    currentFrame.origin.y = self.cropAreaY;
                }
                if (currentFrame.size.width + currentFrame.origin.x < self.cropAreaX + self.cropAreaWidth) {
                    CGFloat movedLeftX = fabs(currentFrame.size.width + currentFrame.origin.x - (self.cropAreaX + self.cropAreaWidth));
                    currentFrame.origin.x += movedLeftX;
                }
                if (currentFrame.size.height + currentFrame.origin.y < self.cropAreaY + self.cropAreaHeight) {
                    CGFloat moveUpY = fabs(currentFrame.size.height + currentFrame.origin.y - (self.cropAreaY + self.cropAreaHeight));
                    currentFrame.origin.y += moveUpY;
                }
                [UIView animateWithDuration:0.3 animations:^{
                    
                    [view setFrame:currentFrame];
                }];
                break;
            }
            default:
                break;
        }
    }
}

-(void)handleCenterPinGesture:(UIPinchGestureRecognizer *)pinGesture
{
    CGFloat scaleRation = 3;
    UIView * view = self.bigImageView;
    
    // 缩放开始与缩放中
    if (pinGesture.state == UIGestureRecognizerStateBegan || pinGesture.state == UIGestureRecognizerStateChanged) {
        // 移动缩放中心到手指中心
        CGPoint pinchCenter = [pinGesture locationInView:view.superview];
        CGFloat distanceX = view.frame.origin.x - pinchCenter.x;
        CGFloat distanceY = view.frame.origin.y - pinchCenter.y;
        CGFloat scaledDistanceX = distanceX * pinGesture.scale;
        CGFloat scaledDistanceY = distanceY * pinGesture.scale;
        CGRect newFrame = CGRectMake(view.frame.origin.x + scaledDistanceX - distanceX, view.frame.origin.y + scaledDistanceY - distanceY, view.frame.size.width * pinGesture.scale, view.frame.size.height * pinGesture.scale);
        view.frame = newFrame;
        pinGesture.scale = 1;
    }
    
    // 缩放结束
    if (pinGesture.state == UIGestureRecognizerStateEnded) {
        CGFloat ration =  view.frame.size.width / self.originalFrame.size.width;
        
        // 缩放过大
        if (ration > 5) {
            CGRect newFrame = CGRectMake(0, 0, self.originalFrame.size.width * scaleRation, self.originalFrame.size.height * scaleRation);
            view.frame = newFrame;
        }
        
        // 缩放过小
        if (ration < 0.25) {
            view.frame = self.originalFrame;
        }
        // 对图片进行位置修正
        CGRect resetPosition = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        
        if (resetPosition.origin.x >= self.cropAreaX) {
            resetPosition.origin.x = self.cropAreaX;
        }
        if (resetPosition.origin.y >= self.cropAreaY) {
            resetPosition.origin.y = self.cropAreaY;
        }
        if (resetPosition.size.width + resetPosition.origin.x < self.cropAreaX + self.cropAreaWidth) {
            CGFloat movedLeftX = fabs(resetPosition.size.width + resetPosition.origin.x - (self.cropAreaX + self.cropAreaWidth));
            resetPosition.origin.x += movedLeftX;
        }
        if (resetPosition.size.height + resetPosition.origin.y < self.cropAreaY + self.cropAreaHeight) {
            CGFloat moveUpY = fabs(resetPosition.size.height + resetPosition.origin.y - (self.cropAreaY + self.cropAreaHeight));
            resetPosition.origin.y += moveUpY;
        }
        view.frame = resetPosition;
        
        // 对图片缩放进行比例修正，防止过小
        if (self.cropAreaX < self.bigImageView.frame.origin.x
            || ((self.cropAreaX + self.cropAreaWidth) > self.bigImageView.frame.origin.x + self.bigImageView.frame.size.width)
            || self.cropAreaY < self.bigImageView.frame.origin.y
            || ((self.cropAreaY + self.cropAreaHeight) > self.bigImageView.frame.origin.y + self.bigImageView.frame.size.height)) {
            view.frame = self.originalFrame;
        }
    }
}

// 裁剪图片并调用返回Block
- (UIImage *)cropImage
{
    CGFloat imageWScale = self.bigImageView.frame.size.width/self.targetImage.size.width;
    CGFloat imageHScale = self.bigImageView.frame.size.height/self.targetImage.size.height;
    CGFloat cropX = (self.cropAreaX - self.bigImageView.frame.origin.x)/imageWScale;
    CGFloat cropY = (self.cropAreaY - self.bigImageView.frame.origin.y)/imageHScale;
    CGFloat cropWidth = self.cropAreaWidth / imageWScale;
    CGFloat cropHeight = self.cropAreaHeight/imageHScale;
    
    CGRect cropRect = CGRectMake(cropX, cropY, cropWidth, cropHeight);
//    cropRect = CGRectMake(self.cropAreaX, self.cropAreaY, (self.cropAreaWidth /  self.bigImageView.frame.size.width) * self.targetImage.size.width, (self.cropAreaHeight / self.bigImageView.frame.size.height) * self.targetImage.size.height);
   
    CGImageRef sourceImageRef = [[self.targetImage fixOrientation] CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}


- (void)setUpCropLayer
{
    self.cropView.layer.sublayers = nil;
    DoodleBoardClipAreaLayer * layer = [[DoodleBoardClipAreaLayer alloc] init];
    
    CGRect cropframe = CGRectMake(self.cropAreaX, self.cropAreaY, self.cropAreaWidth, self.cropAreaHeight);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.cropView.frame cornerRadius:0];
    UIBezierPath * cropPath = [UIBezierPath bezierPathWithRect:cropframe];
    [path appendPath:cropPath];
    layer.path = path.CGPath;
    
    layer.fillRule = kCAFillRuleEvenOdd;
    
    layer.fillColor = self.frameConfig.layerBgColor ? self.frameConfig.layerBgColor.CGColor : [[UIColor blackColor] CGColor];
    layer.opacity = 0.7;
    
    layer.frame = self.cropView.bounds;
    [layer setCropAreaLeft:self.cropAreaX CropAreaTop:self.cropAreaY + self.frameConfig.top CropAreaRight:self.cropAreaX + self.cropAreaWidth CropAreaBottom:self.cropAreaY + self.cropAreaHeight + self.frameConfig.bottom configModel:self.frameConfig];
    [self.cropView.layer addSublayer:layer];
    [self bringSubviewToFront:self.cropView];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.cropView.frame = self.bounds;
    CGFloat tempWidth = 0.0;
    CGFloat tempHeight = 0.0;
    
    if (self.targetImage.size.width/self.cropAreaWidth <= self.targetImage.size.height/self.cropAreaHeight) {
        tempWidth = self.cropAreaWidth;
        tempHeight = (tempWidth/self.targetImage.size.width) * self.targetImage.size.height;
    } else if (self.targetImage.size.width/self.cropAreaWidth > self.targetImage.size.height/self.cropAreaHeight) {
        tempHeight = self.cropAreaHeight;
        tempWidth = (tempHeight/self.targetImage.size.height) * self.targetImage.size.width;
    }
    
    self.bigImageView.frame = CGRectMake(self.cropAreaX - (tempWidth - self.cropAreaWidth) * 0.5, self.cropAreaY - (tempHeight - self.cropAreaHeight) * 0.5, tempWidth, tempHeight);
    self.originalFrame = CGRectMake(self.cropAreaX - (tempWidth - self.cropAreaWidth)/2, self.cropAreaY - (tempHeight - self.cropAreaHeight)/2, tempWidth, tempHeight);
    
}

- (UIImageView *)bigImageView
{
    if (!_bigImageView) {
        _bigImageView = [[UIImageView alloc] init];
        _bigImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _bigImageView;
}

- (UIView *)cropView
{
    if (!_cropView) {
        _cropView = [[UIView alloc] init];
    }
    return _cropView;
}


@end



@interface DoodleBoardClipView()

@property (nonatomic, strong) DoodleBoardClipHandleBottomView *handleView;

@property (nonatomic, strong) DoodleBoardClipHandleView *mainView;

@property (nonatomic, strong) void(^cancleBlock)(void);
@property (nonatomic, strong) void(^editBlock)(UIImage *img);

@property (nonatomic, strong) UIImage *img;

@property (nonatomic, strong) UIImage *preImg;

@property (nonatomic, strong) DoodleBoardClipConfigModel *frameConfig;

@end

@implementation DoodleBoardClipView

+(void)showDoodleBoardClipHandleViewWithImg:(UIImage *)img preImg:(UIImage *)preImg superView:(UIView *)superView frame:(CGRect)frame configModel:(DoodleBoardClipConfigModel *)model{
    DoodleBoardClipView *view = [[DoodleBoardClipView alloc]initWithFrame:frame img:img configModel:model];
    view.preImg = preImg;
    [superView addSubview:view];
    [superView bringSubviewToFront:view];
}

+(void)showDoodleBoardClipHandleViewWithImg:(UIImage *)img preImg:(UIImage *)preImg superView:(UIView *)superView cancleBlock:(void(^)(void))cancleBlock complete:(void(^)(UIImage *img))complete{
    DoodleBoardClipView *view = [[DoodleBoardClipView alloc]initWithFrame:[UIScreen mainScreen].bounds img:img];
    view.cancleBlock = cancleBlock;
    view.editBlock = complete;
    view.preImg = preImg;
    [superView addSubview:view];
    [superView bringSubviewToFront:view];
}

-(instancetype)initWithFrame:(CGRect)frame img:(UIImage *)img configModel:(DoodleBoardClipConfigModel *)model{
    self = [super initWithFrame:frame];
    self.frameConfig = model;
    if (self) {
        self.img = img;
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.mainView];
        [self addSubview:self.handleView];
        self.mainView.frameConfig = model;
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame img:(UIImage *)img{
    self = [super initWithFrame:frame];
    if (self) {
        self.img = img;
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.mainView];
        [self addSubview:self.handleView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.handleView.frame = CGRectZero;
    self.mainView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

-(void)dismiss{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


/**
 确认事件
 */
-(void)didClickDoneComplete:(void(^)(UIImage *img, UIImage *originalImg, CGRect frame))complete{
    UIImage *img = [self.mainView cropImage];
    UIImage *originalImg = self.preImg;
    CGRect frame = CGRectMake(self.mainView.cropAreaX, self.mainView.cropAreaY, self.mainView.cropAreaX + self.mainView.cropAreaWidth, self.mainView.cropAreaY + self.mainView.cropAreaHeight);
    !complete?:complete(img, originalImg, frame);
}

-(DoodleBoardClipHandleBottomView *)handleView{
    if (!_handleView) {
        _handleView = [[DoodleBoardClipHandleBottomView alloc]init];
        _handleView.backgroundColor = [UIColor blackColor];
        _handleView.alpha = 0.7;
        __weak typeof(self)wself = self;
        _handleView.didClickCloseBlock = ^{
            [wself dismiss];
        };
        _handleView.didClickFinishBlock = ^{
            !wself.editBlock?:wself.editBlock([wself.mainView cropImage]);
            [wself dismiss];
        };
        _handleView.didClickTitleBlock = ^{
            wself.mainView.targetImage = wself.preImg;
        };
    }
    return _handleView;
}


-(DoodleBoardClipHandleView *)mainView{
    if (!_mainView) {
        _mainView = [[DoodleBoardClipHandleView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 44) img:self.img];
    }
    return _mainView;
}




@end
