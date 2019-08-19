//
//  DoodleClipView.m
//  AFNetworking
//
//  Created by Hayder on 2019/5/6.
//

#import "DoodleClipView.h"
#define WIDTH(_view) CGRectGetWidth(_view.bounds)
#define HEIGHT(_view) CGRectGetHeight(_view.bounds)
#define MAXX(_view) CGRectGetMaxX(_view.frame)
#define MAXY(_view) CGRectGetMaxY(_view.frame)
#define MINX(_view) CGRectGetMinX(_view.frame)
#define MINY(_view) CGRectGetMinY(_view.frame)
#define MID_LINE_INTERACT_WIDTH 44
#define MID_LINE_INTERACT_HEIGHT 44

#define imageNamed(imageName) [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"%@@2x",imageName] ofType:@"png" inDirectory:@"DoodleManager.bundle"]]

typedef NS_ENUM(NSInteger, CropAreaCornerPosition) {
    CropAreaCornerPositionTopLeft,
    CropAreaCornerPositionTopRight,
    CropAreaCornerPositionBottomLeft,
    CropAreaCornerPositionBottomRight
};
typedef NS_ENUM(NSInteger, MidLineType) {
    
    MidLineTypeTop,
    MidLineTypeBottom,
    MidLineTypeLeft,
    MidLineTypeRight
    
};
@interface UIImage(Handler)
@end
@implementation UIImage(Handler)
//Fix image's rotation
- (UIImage *)fixOrientation {
    
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}
- (UIImage *)imageAtRect:(CGRect)rect
{
    
    UIImage *fixedImage = [self fixOrientation];
    CGImageRef imageRef = CGImageCreateWithImageInRect([fixedImage CGImage], rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
    
}
@end


/**
 边角操作view
 */
@interface CornerView: UIView

@property (assign, nonatomic) CGFloat lineWidth;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) CropAreaCornerPosition cornerPosition;
@property (assign, nonatomic) CornerView *relativeViewX;    //当前view在x轴上的相邻边角view
@property (assign, nonatomic) CornerView *relativeViewY;    //当前view在y轴上的相邻边角view
@property (strong, nonatomic) CAShapeLayer *cornerShapeLayer;

- (void)updateSizeWithWidth: (CGFloat)width height: (CGFloat)height;
@end
@implementation CornerView
- (instancetype)initWithFrame:(CGRect)frame lineColor: (UIColor *)lineColor lineWidth: (CGFloat)lineWidth {
    
    self = [super initWithFrame: frame];
    if(self) {
        self.lineColor = lineColor;
        self.lineWidth = lineWidth;
    }
    return self;
}
- (void)setCornerPosition:(CropAreaCornerPosition)cornerPosition {
    
    _cornerPosition = cornerPosition;
    [self drawCornerLines];
    
}
- (void)setLineWidth:(CGFloat)lineWidth {
    
    _lineWidth = lineWidth;
    [self drawCornerLines];
    
}
- (void)drawCornerLines {
    
    if(_cornerShapeLayer && _cornerShapeLayer.superlayer) {
        [_cornerShapeLayer removeFromSuperlayer];
    }
    _cornerShapeLayer = [CAShapeLayer layer];
    _cornerShapeLayer.lineWidth = _lineWidth;
    _cornerShapeLayer.strokeColor = _lineColor.CGColor;
    _cornerShapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *cornerPath = [UIBezierPath bezierPath];
    CGFloat paddingX = _lineWidth / 2.0f;
    CGFloat paddingY = _lineWidth / 2.0f;
    switch (_cornerPosition) {
        case CropAreaCornerPositionTopLeft: {
            [cornerPath moveToPoint:CGPointMake(WIDTH(self), paddingY)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, HEIGHT(self))];
            break;
        }
        case CropAreaCornerPositionTopRight: {
            [cornerPath moveToPoint:CGPointMake(0, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, HEIGHT(self))];
            break;
        }
        case CropAreaCornerPositionBottomLeft: {
            [cornerPath moveToPoint:CGPointMake(paddingX, 0)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, HEIGHT(self) - paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self), HEIGHT(self) - paddingY)];
            break;
        }
        case CropAreaCornerPositionBottomRight: {
            [cornerPath moveToPoint:CGPointMake(WIDTH(self) - paddingX, 0)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, HEIGHT(self) - paddingY)];
            [cornerPath addLineToPoint:CGPointMake(0, HEIGHT(self) - paddingY)];
            break;
        }
        default:
            break;
    }
    _cornerShapeLayer.path = cornerPath.CGPath;
    [self.layer addSublayer: _cornerShapeLayer];
    
}
- (void)updateSizeWithWidth: (CGFloat)width height: (CGFloat)height {
    
    switch (_cornerPosition) {
        case CropAreaCornerPositionTopLeft: {
            self.frame = CGRectMake(MINX(self), MINY(self), width, height);
            break;
        }
        case CropAreaCornerPositionTopRight: {
            self.frame = CGRectMake(MAXX(self) - width, MINY(self), width, height);
            break;
        }
        case CropAreaCornerPositionBottomLeft: {
            self.frame = CGRectMake(MINX(self), MAXY(self) - height, width, height);
            break;
        }
        case CropAreaCornerPositionBottomRight: {
            self.frame = CGRectMake(MAXX(self) - width, MAXY(self) - height, width, height);
            break;
        }
        default:
            break;
    }
    [self drawCornerLines];
    
}
- (void)setLineColor:(UIColor *)lineColor {
    
    _lineColor = lineColor;
    _cornerShapeLayer.strokeColor = lineColor.CGColor;
    
}
@end


/**
 边框线中间的凸起线
 */
@interface MidLineView : UIView
@property (strong, nonatomic) CAShapeLayer *lineLayer;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) CGFloat lineHeight;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) MidLineType type;
@end
@implementation MidLineView
- (instancetype)initWithLineWidth: (CGFloat)lineWidth lineHeight: (CGFloat)lineHeight lineColor: (UIColor *)lineColor {
    
    self = [super initWithFrame: CGRectMake(0, 0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT)];
    if(self) {
        self.lineWidth = lineWidth;
        self.lineHeight = lineHeight;
        self.lineColor = lineColor;
    }
    return self;
    
}
- (void)setType:(MidLineType)type {
    
    _type = type;
    [self drawMidLine];
    
}
- (void)setLineWidth:(CGFloat)lineWidth {
    
    _lineWidth = lineWidth;
    [self drawMidLine];
    
}
- (void)setLineColor:(UIColor *)lineColor {
    
    _lineColor = lineColor;
    _lineLayer.strokeColor = lineColor.CGColor;
    
}
- (void)setLineHeight:(CGFloat)lineHeight {
    
    _lineHeight = lineHeight;
    _lineLayer.lineWidth = lineHeight;
    
}
- (void)drawMidLine {
    
    if(_lineLayer && _lineLayer.superlayer) {
        [_lineLayer removeFromSuperlayer];
    }
    _lineLayer = [CAShapeLayer layer];
    _lineLayer.strokeColor = _lineColor.CGColor;
    _lineLayer.lineWidth = _lineHeight;
    _lineLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *midLinePath = [UIBezierPath bezierPath];
    switch (_type) {
        case MidLineTypeTop:
        case MidLineTypeBottom: {
            [midLinePath moveToPoint:CGPointMake((WIDTH(self) - _lineWidth) / 2.0, HEIGHT(self) / 2.0)];
            [midLinePath addLineToPoint:CGPointMake((WIDTH(self) + _lineWidth) / 2.0, HEIGHT(self) / 2.0)];
            break;
        }
        case MidLineTypeRight:
        case MidLineTypeLeft: {
            [midLinePath moveToPoint:CGPointMake(WIDTH(self) / 2.0, (HEIGHT(self) - _lineWidth) / 2.0)];
            [midLinePath addLineToPoint:CGPointMake(WIDTH(self) / 2.0, (HEIGHT(self) + _lineWidth) / 2.0)];
            break;
        }
        default:
            break;
    }
    _lineLayer.path = midLinePath.CGPath;
    [self.layer addSublayer: _lineLayer];
    
}
@end


/**
 裁剪框区域
 */
@interface CropAreaView : UIView
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) CAShapeLayer *borderLayer;
@end
@implementation CropAreaView

- (instancetype)init {
    
    self = [super init];
    if(self) {
        [self createBorderLayer];
    }
    return self;
}
- (void)setFrame:(CGRect)frame {
    
    [super setFrame: frame];
    [self resetBorderLayerPath];
    
}
- (void)setBounds:(CGRect)bounds {
    
    [super setBounds:bounds];
    [self resetBorderLayerPath];
    
}

- (void)createBorderLayer {
    
    if(_borderLayer && _borderLayer.superlayer) {
        [_borderLayer removeFromSuperlayer];
    }
    _borderLayer = [CAShapeLayer layer];
    [self.layer addSublayer: _borderLayer];
    
}
- (void)resetBorderLayerPath {
    
    UIBezierPath *layerPath = [UIBezierPath bezierPathWithRect: CGRectMake(_borderWidth / 2.0f, _borderWidth / 2.0f, WIDTH(self) - _borderWidth, HEIGHT(self) - _borderWidth)];
    _borderLayer.lineWidth = _borderWidth;
    _borderLayer.fillColor = nil;
    _borderLayer.path = layerPath.CGPath;
    
}
- (void)setBorderWidth:(CGFloat)borderWidth {
    
    _borderWidth = borderWidth;
    [self resetBorderLayerPath];
    
}
- (void)setBorderColor:(UIColor *)borderColor {
    
    _borderColor = borderColor;
    _borderLayer.strokeColor = borderColor.CGColor;
    
}
- (UIView *) hitTest:(CGPoint) point withEvent:(UIEvent *)event {
    
    for(UIView *subView in self.subviews) {
        if(CGRectContainsPoint(subView.frame, point)) {
            return subView;
        }
    }
    if(CGRectContainsPoint(self.bounds, point)) {
        return self;
    }
    return nil;
    
}
@end


@interface DoodleClipView() {
    
    CGFloat currentMinSpace;
    
}
@property (strong, nonatomic) UIView *cropMaskView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) CornerView *topLeftCorner;
@property (strong, nonatomic) CornerView *topRightCorner;
@property (strong, nonatomic) CornerView *bottomLeftCorner;
@property (strong, nonatomic) CornerView *bottomRightCorner;
@property (strong, nonatomic) CropAreaView *cropAreaView;
@property (strong, nonatomic) UIPanGestureRecognizer *topLeftPan;
@property (strong, nonatomic) UIPanGestureRecognizer *topRightPan;
@property (strong, nonatomic) UIPanGestureRecognizer *bottomLeftPan;
@property (strong, nonatomic) UIPanGestureRecognizer *bottomRightPan;
@property (strong, nonatomic) UIPanGestureRecognizer *cropAreaPan;
@property (strong, nonatomic) UIPinchGestureRecognizer *cropAreaPinch;
@property (assign, nonatomic) CGSize pinchOriSize;
@property (assign, nonatomic) CGPoint cropAreaOriCenter;
@property (assign, nonatomic) CGRect cropAreaOriFrame;
@property (strong, nonatomic) MidLineView *topMidLine;
@property (strong, nonatomic) MidLineView *leftMidLine;
@property (strong, nonatomic) MidLineView *bottomMidLine;
@property (strong, nonatomic) MidLineView *rightMidLine;
@property (strong, nonatomic) UIPanGestureRecognizer *topMidPan;
@property (strong, nonatomic) UIPanGestureRecognizer *bottomMidPan;
@property (strong, nonatomic) UIPanGestureRecognizer *leftMidPan;
@property (strong, nonatomic) UIPanGestureRecognizer *rightMidPan;
@property (assign, nonatomic) CGFloat paddingLeftRight;     //图片左右距离边缘距离
@property (assign, nonatomic) CGFloat paddingTopBottom;     //图片上下距离边缘距离
@property (assign, nonatomic) CGFloat imageAspectRatio;     //图片宽高比
@property (assign, nonatomic, readonly) CGFloat cornerMargin;
@property (nonatomic, strong) UIButton  *btnOK;
@property (nonatomic, strong) UIButton  *btnCancel;

@end


@implementation DoodleClipView


- (instancetype)initWithFrame:(CGRect)frame configModel:(DoodleBoardClipConfigModel *)configModel{
    
    self = [super initWithFrame: frame];
    self.configModel = configModel;
    if(self) {
        [self commonInit];
    }
    return self;
    
}
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: frame];
    if(self) {
        [self commonInit];
    }
    return self;
    
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder: aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
    
}
- (void)commonInit {
    
    [self setUp];
    [self createCorners];
    [self resetCropAreaOnCornersFrameChanged];
    [self bindPanGestures];
    
}
- (void)dealloc {
    
    [_cropAreaView removeObserver: self forKeyPath: @"frame"];
    [_cropAreaView removeObserver: self forKeyPath: @"center"];
    [_imageView removeObserver: self forKeyPath: @"frame"];
    
}
- (void)setUp {
    
    //默认属性
    UIColor *defaultColor = [UIColor colorWithWhite: 1 alpha: 0.8];
    _cropAreaBorderLineColor = defaultColor;
    _cropAreaCornerLineColor = self.configModel.tintColor ? self.configModel.tintColor : [UIColor redColor];
    _cropAreaBorderLineWidth = 2;
    _cropAreaCornerLineWidth = 4;
    _cropAreaCornerWidth = 20;
    _cropAreaCornerHeight = 20;
    _cropAspectRatio = 0;
    _minSpace = 10;
    currentMinSpace = _minSpace;
    _cropAreaMidLineWidth = 20;
    _cropAreaMidLineHeight = 4;
    _cropAreaMidLineColor = defaultColor;
    _maskAlpha = 0.6;
    _needScaleCrop = NO;
    _showMidLines = YES;
    _initialScaleFactor = 0.5;
    _cornerBorderInImage = NO;
    _showInsideCropButton = self.configModel ? self.configModel.isShowHandle : NO;
    _btnCropWH = _cropAreaCornerWidth;
    
    _imageView = [[UIImageView alloc]initWithFrame: self.bounds];
    _imageView.contentMode = UIViewContentModeScaleToFill;
    _imageView.userInteractionEnabled = YES;
    _imageAspectRatio = 0;
    [self addSubview: _imageView];
    
    _cropMaskView = [[UIView alloc]initWithFrame: _imageView.bounds];
    _cropMaskView.backgroundColor = self.configModel.layerBgColor ? self.configModel.layerBgColor : [UIColor colorWithRed:0 green:0 blue:0 alpha:_maskAlpha];[UIColor colorWithRed:0 green:0 blue:0 alpha:_maskAlpha];
    _cropMaskView.alpha = _maskAlpha;
    _cropMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_imageView addSubview: _cropMaskView];
    
    _cropAreaView = [[CropAreaView alloc] init];
    _cropAreaView.borderWidth = _cropAreaBorderLineWidth;
    _cropAreaView.borderColor = _cropAreaBorderLineColor;
    _cropAreaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_imageView addSubview: _cropAreaView];
    
    [_cropAreaView addObserver: self
                    forKeyPath: @"frame"
                       options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context: NULL];
    [_cropAreaView addObserver: self
                    forKeyPath: @"center"
                       options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context: NULL];
    [_imageView addObserver: self
                 forKeyPath: @"frame"
                    options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                    context: NULL];
    
}
#pragma mark - PanGesture Bind
- (void)bindPanGestures {
    
    _topLeftPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _topRightPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _bottomLeftPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _bottomRightPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _cropAreaPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCropAreaPan:)];
    
    [_topLeftCorner addGestureRecognizer: _topLeftPan];
    [_topRightCorner addGestureRecognizer: _topRightPan];
    [_bottomLeftCorner addGestureRecognizer: _bottomLeftPan];
    [_bottomRightCorner addGestureRecognizer: _bottomRightPan];
    [_cropAreaView addGestureRecognizer: _cropAreaPan];
    
}
#pragma mark - PinchGesture CallBack
- (void)handleCropAreaPinch: (UIPinchGestureRecognizer *)pinchGesture {
    
    switch (pinchGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _pinchOriSize = _cropAreaView.frame.size;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self resetCropAreaByScaleFactor: pinchGesture.scale];
            break;
        }
        default:
            break;
    }
    
}
#pragma mark - PanGesture CallBack
- (void)handleCropAreaPan: (UIPanGestureRecognizer *)panGesture {
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _cropAreaOriCenter = _cropAreaView.center;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGesture translationInView: _imageView];
            CGPoint willCenter = CGPointMake(_cropAreaOriCenter.x + translation.x, _cropAreaOriCenter.y + translation.y);
            CGFloat centerMinX = WIDTH(_cropAreaView) / 2.0f + self.cornerMargin * _cornerBorderInImage ;
            CGFloat centerMaxX = WIDTH(_imageView) - WIDTH(_cropAreaView) / 2.0f - self.cornerMargin * _cornerBorderInImage;
            CGFloat centerMinY = HEIGHT(_cropAreaView) / 2.0f + self.cornerMargin * _cornerBorderInImage;
            CGFloat centerMaxY = HEIGHT(_imageView) - HEIGHT(_cropAreaView) / 2.0f - self.cornerMargin * _cornerBorderInImage;
            _cropAreaView.center = CGPointMake(MIN(MAX(centerMinX, willCenter.x), centerMaxX), MIN(MAX(centerMinY, willCenter.y), centerMaxY));
            [self resetCornersOnCropAreaFrameChanged];
            break;
        }
        default:
            break;
    }
    
}
- (void)handleMidPan: (UIPanGestureRecognizer *)panGesture {
    
    MidLineView *midLineView = (MidLineView *)panGesture.view;
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _cropAreaOriFrame = _cropAreaView.frame;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGesture translationInView: _cropAreaView];
            switch (midLineView.type) {
                case MidLineTypeTop: {
                    CGFloat minHeight = currentMinSpace + (_cropAreaCornerHeight - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxHeight = CGRectGetMaxY(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth) * self.cornerBorderInImage;
                    CGFloat willHeight = MIN(MAX(minHeight, CGRectGetHeight(_cropAreaOriFrame) - translation.y), maxHeight);
                    CGFloat deltaY = willHeight - CGRectGetHeight(_cropAreaOriFrame);
                    _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), CGRectGetMinY(_cropAreaOriFrame) - deltaY, CGRectGetWidth(_cropAreaOriFrame), willHeight);
                    break;
                }
                case MidLineTypeBottom: {
                    CGFloat minHeight = currentMinSpace + (_cropAreaCornerHeight - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxHeight = HEIGHT(_imageView) - CGRectGetMinY(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth) * self.cornerBorderInImage;
                    CGFloat willHeight = MIN(MAX(minHeight, CGRectGetHeight(_cropAreaOriFrame) + translation.y), maxHeight);
                    _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), CGRectGetMinY(_cropAreaOriFrame), CGRectGetWidth(_cropAreaOriFrame), willHeight);
                    break;
                }
                case MidLineTypeLeft: {
                    CGFloat minWidth = currentMinSpace + (_cropAreaCornerWidth - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxWidth = CGRectGetMaxX(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth) * self.cornerBorderInImage;
                    CGFloat willWidth = MIN(MAX(minWidth, CGRectGetWidth(_cropAreaOriFrame) - translation.x), maxWidth);
                    CGFloat deltaX = willWidth - CGRectGetWidth(_cropAreaOriFrame);
                    _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame) - deltaX, CGRectGetMinY(_cropAreaOriFrame), willWidth, CGRectGetHeight(_cropAreaOriFrame));
                    break;
                }
                case MidLineTypeRight: {
                    CGFloat minWidth = currentMinSpace + (_cropAreaCornerWidth - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxWidth = WIDTH(_imageView) - CGRectGetMinX(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth) * self.cornerBorderInImage;
                    CGFloat willWidth = MIN(MAX(minWidth, CGRectGetWidth(_cropAreaOriFrame) + translation.x), maxWidth);
                    _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), CGRectGetMinY(_cropAreaOriFrame), willWidth, CGRectGetHeight(_cropAreaOriFrame));
                    break;
                }
                default:
                    break;
            }
            [self resetCornersOnCropAreaFrameChanged];
            break;
        }
        default:
            break;
    }
    
}
- (void)handleCornerPan: (UIPanGestureRecognizer *)panGesture {
    
    CornerView *panView = (CornerView *)panGesture.view;
    CornerView *relativeViewX = panView.relativeViewX;
    CornerView *relativeViewY = panView.relativeViewY;
    CGPoint locationInImageView = [panGesture locationInView: _imageView];
    NSInteger xFactor = MINX(relativeViewY) > MINX(panView) ? -1 : 1;
    NSInteger yFactor = MINY(relativeViewX) > MINY(panView) ? -1 : 1;
    CGFloat approachAspectRatio = 0;
    if(panView == _topLeftCorner) {
        approachAspectRatio = (MINX(panView) + self.cornerMargin) / (MINY(panView) + self.cornerMargin);
    }
    else if(panView == _topRightCorner) {
        approachAspectRatio = (WIDTH(_imageView) - MAXX(panView) + self.cornerMargin) / (MINY(panView) + self.cornerMargin);
    }
    else if(panView == _bottomLeftCorner) {
        approachAspectRatio = (MINX(panView) + self.cornerMargin) / (HEIGHT(_imageView) - MAXY(panView) + self.cornerMargin);
    }
    else if(panView == _bottomRightCorner) {
        approachAspectRatio = (WIDTH(_imageView) - MAXX(panView) + self.cornerMargin) /(HEIGHT(_imageView) - MAXY(panView) + self.cornerMargin);
    }
    
    CGFloat spaceX = MIN(MAX((locationInImageView.x - relativeViewY.center.x) * xFactor + _cropAreaCornerWidth - self.cornerMargin * 2, currentMinSpace + _cropAreaCornerWidth * 2 - self.cornerMargin * 2), xFactor < 0 ? relativeViewY.center.x + _cropAreaCornerWidth / 2.0 - self.cornerMargin * 2 + self.cornerMargin * !_cornerBorderInImage : WIDTH(_imageView) - relativeViewY.center.x + _cropAreaCornerWidth / 2.0 - self.cornerMargin * 2 + self.cornerMargin * !_cornerBorderInImage);
    
    CGFloat spaceY = MIN(MAX((locationInImageView.y - relativeViewX.center.y) * yFactor + _cropAreaCornerHeight - self.cornerMargin * 2, currentMinSpace + _cropAreaCornerHeight * 2 - self.cornerMargin * 2), yFactor < 0 ? relativeViewX.center.y + _cropAreaCornerHeight / 2.0 - self.cornerMargin * 2 + self.cornerMargin * !_cornerBorderInImage : HEIGHT(_imageView) - relativeViewX.center.y + _cropAreaCornerHeight / 2.0 - self.cornerMargin * 2 + self.cornerMargin * !_cornerBorderInImage);
    
    if(_cropAspectRatio > 0) {
        if(_cropAspectRatio >= approachAspectRatio) {
            spaceY = MAX(spaceX / _cropAspectRatio, currentMinSpace + _cropAreaCornerHeight * 2 - self.cornerMargin * 2);
            spaceX = spaceY * _cropAspectRatio;
        }
        else {
            spaceX = MAX(spaceY * _cropAspectRatio, currentMinSpace + _cropAreaCornerWidth * 2 - self.cornerMargin * 2);
            spaceY = spaceX / _cropAspectRatio;
        }
    }
    
    CGFloat centerX = (spaceX - _cropAreaCornerWidth + self.cornerMargin * 2) * xFactor + relativeViewY.center.x;
    CGFloat centerY = (spaceY - _cropAreaCornerHeight + self.cornerMargin * 2) * yFactor + relativeViewX.center.y;
    panView.center = CGPointMake(centerX, centerY);
    relativeViewX.frame = CGRectMake(MINX(panView), MINY(relativeViewX), WIDTH(relativeViewX), HEIGHT(relativeViewX));
    relativeViewY.frame = CGRectMake(MINX(relativeViewY), MINY(panView), WIDTH(relativeViewY), HEIGHT(relativeViewY));
    [self resetCropAreaOnCornersFrameChanged];
    [self resetCropTransparentArea];
    
}
#pragma mark - Position/Resize Corners&CropArea
- (void)resetCropButton{
    if (!_showInsideCropButton) return;
    
    if (_btnOK == nil || _btnCancel == nil){
        [self createCropButton];
    }
    //重设frame
    CGFloat _margin = 5;
    
    CGFloat bottomMargin = HEIGHT(_imageView) - MAXY(_bottomRightCorner);
    
    //底部有空间
    if (bottomMargin > _cropAreaCornerWidth*2){
        _btnCancel.frame = CGRectMake(MAXX(_bottomRightCorner)-_btnCropWH, MAXY(_bottomRightCorner)+_margin, _btnCropWH, _btnCropWH);
        _btnOK.frame = CGRectMake(_btnCancel.frame.origin.x-_btnCropWH-_margin, _btnCancel.frame.origin.y, _btnCropWH, _btnCropWH);
    }else{
        //裁剪框高度大于一半图片，就在里面
        if (HEIGHT(_cropAreaView) > HEIGHT(_imageView)*2/3){
            _btnCancel.frame = CGRectMake(MINX(_bottomRightCorner)-_btnCropWH, MINY(_bottomRightCorner)-_btnCropWH, _btnCropWH, _btnCropWH);
            _btnOK.frame = CGRectMake(_btnCancel.frame.origin.x-_btnCropWH-_margin, _btnCancel.frame.origin.y, _btnCropWH, _btnCropWH);
        }else{
            _btnCancel.frame = CGRectMake(MAXX(_topRightCorner)-_btnCropWH, MINY(_topRightCorner)-_margin-_btnCropWH, _btnCropWH, _btnCropWH);
            _btnOK.frame = CGRectMake(_btnCancel.frame.origin.x-_btnCropWH-_margin,_btnCancel.frame.origin.y, _btnCropWH, _btnCropWH);
        }
    }
    
}

- (void)resetCornersOnCropAreaFrameChanged {
    CGFloat cornerMargin = 0;   //考虑边角外突5px，便于更好操作，先不做
    
    _topLeftCorner.frame = CGRectMake(MINX(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth-cornerMargin, MINY(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth-cornerMargin, _cropAreaCornerWidth, _cropAreaCornerHeight);
    _topRightCorner.frame = CGRectMake(MAXX(_cropAreaView) - _cropAreaCornerWidth + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth+cornerMargin, MINY(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth-cornerMargin, _cropAreaCornerWidth, _cropAreaCornerHeight);
    _bottomLeftCorner.frame = CGRectMake(MINX(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth-cornerMargin, MAXY(_cropAreaView) - _cropAreaCornerHeight + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth+cornerMargin, _cropAreaCornerWidth, _cropAreaCornerHeight);
    _bottomRightCorner.frame = CGRectMake(MAXX(_cropAreaView) - _cropAreaCornerWidth + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth+cornerMargin, MAXY(_cropAreaView) - _cropAreaCornerHeight + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth+cornerMargin, _cropAreaCornerWidth, _cropAreaCornerHeight);
    
}

- (void)resetCropAreaOnCornersFrameChanged {
    
    _cropAreaView.frame = CGRectMake(MINX(_topLeftCorner) + self.cornerMargin, MINY(_topLeftCorner) + self.cornerMargin, MAXX(_topRightCorner) - MINX(_topLeftCorner) - self.cornerMargin * 2, MAXY(_bottomLeftCorner) - MINY(_topLeftCorner) - self.cornerMargin * 2);
    
    
}
- (void)resetMinSpaceIfNeeded {
    
    CGFloat willMinSpace = MIN(WIDTH(_cropAreaView) - _cropAreaCornerWidth * 2 + self.cornerMargin * 2, HEIGHT(_cropAreaView) - _cropAreaCornerHeight * 2 + self.cornerMargin * 2);
    currentMinSpace = MIN(willMinSpace, _minSpace);
    
}
- (void)resetCropTransparentArea {
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect: _imageView.bounds];
    UIBezierPath *clearPath = [[UIBezierPath bezierPathWithRect: _cropAreaView.frame] bezierPathByReversingPath];
    [path appendPath: clearPath];
    CAShapeLayer *shapeLayer = (CAShapeLayer *)_cropMaskView.layer.mask;
    if(!shapeLayer) {
        shapeLayer = [CAShapeLayer layer];
        [_cropMaskView.layer setMask: shapeLayer];
    }
    shapeLayer.path = path.CGPath;
    
    [self resetCropButton];
    
}
- (void)resetCornersOnSizeChanged {
    
    [_topLeftCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    [_topRightCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    [_bottomLeftCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    [_bottomRightCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    
}

- (void)createCropButton {
    _btnOK = [[UIButton alloc] init];
    _btnOK.backgroundColor = [UIColor clearColor];
    [_btnOK setBackgroundImage: imageNamed(@"icon_gou") forState:UIControlStateNormal];
    [_btnOK setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnOK.titleLabel.font = [UIFont systemFontOfSize:40];
    [_btnOK addTarget:self action:@selector(clickOkBtn) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_btnOK];
    
    _btnCancel = [[UIButton alloc] init];
    _btnCancel.backgroundColor = [UIColor clearColor];
    [_btnCancel setBackgroundImage:imageNamed(@"icon_cha") forState:UIControlStateNormal];
    [_btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnCancel.titleLabel.font = [UIFont systemFontOfSize:40];
    [_btnCancel addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_btnCancel];
    
}

- (void)createCorners {
    _topLeftCorner = [[CornerView alloc]initWithFrame: CGRectMake(0, 0, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor:_cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _topLeftCorner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    _topLeftCorner.cornerPosition = CropAreaCornerPositionTopLeft;
    
    _topRightCorner = [[CornerView alloc]initWithFrame: CGRectMake(WIDTH(_imageView) -  _cropAreaCornerWidth, 0, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor: _cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _topRightCorner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    _topRightCorner.cornerPosition = CropAreaCornerPositionTopRight;
    
    _bottomLeftCorner = [[CornerView alloc]initWithFrame: CGRectMake(0, HEIGHT(_imageView) -  _cropAreaCornerHeight, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor: _cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _bottomLeftCorner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    _bottomLeftCorner.cornerPosition = CropAreaCornerPositionBottomLeft;
    
    _bottomRightCorner = [[CornerView alloc]initWithFrame: CGRectMake(WIDTH(_imageView) - _cropAreaCornerWidth, HEIGHT(_imageView) -  _cropAreaCornerHeight, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor: _cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _bottomRightCorner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    _bottomRightCorner.cornerPosition = CropAreaCornerPositionBottomRight;
    
    _topLeftCorner.relativeViewX = _bottomLeftCorner;
    _topLeftCorner.relativeViewY = _topRightCorner;
    
    _topRightCorner.relativeViewX = _bottomRightCorner;
    _topRightCorner.relativeViewY = _topLeftCorner;
    
    _bottomLeftCorner.relativeViewX = _topLeftCorner;
    _bottomLeftCorner.relativeViewY = _bottomRightCorner;
    
    _bottomRightCorner.relativeViewX = _topRightCorner;
    _bottomRightCorner.relativeViewY = _bottomLeftCorner;
    
    [_imageView addSubview: _topLeftCorner];
    [_imageView addSubview: _topRightCorner];
    [_imageView addSubview: _bottomLeftCorner];
    [_imageView addSubview: _bottomRightCorner];
    
}
- (void)createMidLines {
    
    if(_topMidLine && _bottomMidLine && _leftMidLine && _rightMidLine) return;
    _topMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _topMidLine.type = MidLineTypeTop;
    
    _bottomMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _bottomMidLine.type = MidLineTypeBottom;
    
    _leftMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _leftMidLine.type = MidLineTypeLeft;
    
    _rightMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _rightMidLine.type = MidLineTypeRight;
    
    _topMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_topMidLine addGestureRecognizer: _topMidPan];
    
    _bottomMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_bottomMidLine addGestureRecognizer: _bottomMidPan];
    
    _leftMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_leftMidLine addGestureRecognizer: _leftMidPan];
    
    _rightMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_rightMidLine addGestureRecognizer: _rightMidPan];
    
    [_cropAreaView addSubview: _topMidLine];
    [_cropAreaView addSubview: _bottomMidLine];
    [_cropAreaView addSubview: _leftMidLine];
    [_cropAreaView addSubview: _rightMidLine];
    
}
- (void)removeMidLines {
    
    [_topMidLine removeFromSuperview];
    [_bottomMidLine removeFromSuperview];
    [_leftMidLine removeFromSuperview];
    [_rightMidLine removeFromSuperview];
    
    _topMidLine = nil;
    _bottomMidLine = nil;
    _leftMidLine = nil;
    _rightMidLine = nil;
    
}
- (void)resetMidLines {
    
    CGFloat lineMargin = _cropAreaMidLineHeight / 2.0 - _cropAreaBorderLineWidth;
    _topMidLine.frame = CGRectMake((WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH) / 2.0, - MID_LINE_INTERACT_HEIGHT / 2.0 - lineMargin, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    _bottomMidLine.frame = CGRectMake((WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH) / 2.0, HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT / 2.0 + lineMargin, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    _leftMidLine.frame = CGRectMake(- MID_LINE_INTERACT_WIDTH / 2.0 - lineMargin, (HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT) / 2.0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    _rightMidLine.frame = CGRectMake(WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH / 2.0 + lineMargin, (HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT) / 2.0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    
}

/**
 根据图片宽高比，设置_imageView的frame
 */
- (void)resetImageView {
    
    CGFloat selfAspectRatio = WIDTH(self) / HEIGHT(self);
    if(_imageAspectRatio > selfAspectRatio) {
        _paddingLeftRight = 0;
        _paddingTopBottom = floor((HEIGHT(self) - WIDTH(self) / _imageAspectRatio) / 2.0);
        _imageView.frame = CGRectMake(0, _paddingTopBottom, WIDTH(self), floor(WIDTH(self) / _imageAspectRatio));
    }
    else {
        _paddingTopBottom = 0;
        _paddingLeftRight = floor((WIDTH(self) - HEIGHT(self) * _imageAspectRatio) / 2.0);
        _imageView.frame = CGRectMake(_paddingLeftRight, 0, floor(HEIGHT(self) * _imageAspectRatio), HEIGHT(self));
    }
    
}
- (void)resetCropAreaByAspectRatio {
    if(_imageAspectRatio == 0) return;
    CGFloat tmpCornerMargin = self.cornerMargin * _cornerBorderInImage;
    CGFloat width, height;
    if(_cropAspectRatio == 0) {
        width = (WIDTH(_imageView) - 2 * tmpCornerMargin) * _initialScaleFactor;
        height = (HEIGHT(_imageView) - 2 * tmpCornerMargin) * _initialScaleFactor;
        if(_showMidLines) {
            [self createMidLines];
            [self resetMidLines];
        }
    }
    else {
        [self removeMidLines];
        if(_imageAspectRatio > _cropAspectRatio) {
            height = (HEIGHT(_imageView) - 2 * tmpCornerMargin) * _initialScaleFactor;
            width = height * _cropAspectRatio;
        }
        else {
            width = (WIDTH(_imageView) - 2 * tmpCornerMargin) * _initialScaleFactor;
            height = width / _cropAspectRatio;
        }
    }
    
    if (self.configModel) {
        _cropAreaView.frame = CGRectMake(self.configModel.left, self.configModel.top, WIDTH(_imageView) - self.configModel.left - self.configModel.right, HEIGHT(_imageView) - self.configModel.top - self.configModel.bottom);
    }else{
        _cropAreaView.frame = CGRectMake((WIDTH(_imageView) - width) / 2.0, (HEIGHT(_imageView) - height) / 2.0, width, height);
    }
    
    [self resetCornersOnCropAreaFrameChanged];
    [self resetCropTransparentArea];
    [self resetMinSpaceIfNeeded];
    
}
- (void)resetCropAreaByScaleFactor: (CGFloat)scaleFactor {
    
    CGPoint center = _cropAreaView.center;
    CGFloat tmpCornerMargin = self.cornerMargin * _cornerBorderInImage;
    CGFloat width = _pinchOriSize.width * scaleFactor;
    CGFloat height = _pinchOriSize.height * scaleFactor;
    CGFloat widthMax = MIN(WIDTH(_imageView) - center.x - tmpCornerMargin, center.x - tmpCornerMargin) * 2;
    CGFloat widthMin = currentMinSpace + _cropAreaCornerWidth * 2.0 - tmpCornerMargin * 2.0;
    CGFloat heightMax = MIN(HEIGHT(_imageView) - center.y - tmpCornerMargin, center.y - tmpCornerMargin) * 2;
    CGFloat heightMin = currentMinSpace + _cropAreaCornerWidth * 2.0 - tmpCornerMargin * 2;
    
    BOOL isMinimum = NO;
    if(_cropAspectRatio > 1) {
        if(height <= heightMin) {
            height = heightMin;
            width = height * _cropAspectRatio;
            isMinimum = YES;
        }
    }
    else {
        if(width <= widthMin) {
            width = widthMin;
            height = width / (_cropAspectRatio == 0 ? 1 : _cropAspectRatio);
            isMinimum = YES;
        }
    }
    if(!isMinimum) {
        if(_cropAspectRatio == 0) {
            if(width >= widthMax) {
                width = MIN(width, WIDTH(_imageView) - 2 * tmpCornerMargin);
                center.x = center.x > WIDTH(_imageView) / 2.0 ? WIDTH(_imageView) - width / 2.0 - tmpCornerMargin : width / 2.0 + tmpCornerMargin;
            }
            if(height > heightMax) {
                height = MIN(height, HEIGHT(_imageView) - 2 * tmpCornerMargin);
                center.y = center.y > HEIGHT(_imageView) / 2.0 ? HEIGHT(_imageView) - height / 2.0 - tmpCornerMargin : height / 2.0 + tmpCornerMargin;
            }
            
        }
        else if(_imageAspectRatio > _cropAspectRatio) {
            if(height >= heightMax) {
                height = MIN(height, HEIGHT(_imageView) - 2 * tmpCornerMargin);
                center.y = center.y > HEIGHT(_imageView) / 2.0 ? HEIGHT(_imageView) - height / 2.0 - tmpCornerMargin : height / 2.0 + tmpCornerMargin;
            }
            width = height * _cropAspectRatio;
            if(width > widthMax) {
                center.x = center.x > WIDTH(_imageView) / 2.0 ? WIDTH(_imageView) - width / 2.0 - tmpCornerMargin : width / 2.0 + tmpCornerMargin;
            }
        }
        else {
            if(width >= widthMax) {
                width = MIN(width, WIDTH(_imageView) - 2 * tmpCornerMargin);
                center.x = center.x > WIDTH(_imageView) / 2.0 ? WIDTH(_imageView) - width / 2.0 - tmpCornerMargin : width / 2.0 + tmpCornerMargin;
            }
            height = width / _cropAspectRatio;
            if(height > heightMax) {
                center.y = center.y > HEIGHT(_imageView) / 2.0 ? HEIGHT(_imageView) - height / 2.0 - tmpCornerMargin : height / 2.0 + tmpCornerMargin;
            }
        }
    }
    _cropAreaView.bounds = CGRectMake(0, 0, width, height);
    _cropAreaView.center = center;
    [self resetCornersOnCropAreaFrameChanged];
    
}
#pragma mark - Setter & Getters
- (void)setInitialScaleFactor:(CGFloat)initialScaleFactor {
    
    _initialScaleFactor = MIN(1.0f, initialScaleFactor);
    [self resetCropAreaByAspectRatio];
}
- (CGFloat)cornerMargin {
    
    return _cropAreaCornerLineWidth - _cropAreaBorderLineWidth;
    
}

- (void)setMinSpace:(CGFloat)minSpace {
    
    _minSpace = minSpace;
    currentMinSpace = minSpace;
    
}
- (void)setToCropImage:(UIImage *)toCropImage {
    
    _toCropImage = toCropImage;
    _imageAspectRatio = toCropImage.size.width / toCropImage.size.height;
    _imageView.image = toCropImage;
    [self resetImageView];
    [self resetCropAreaByAspectRatio];
    
}
- (void)setNeedScaleCrop:(BOOL)needScaleCrop {
    
    if(needScaleCrop) {
        _cropAreaPinch = [[UIPinchGestureRecognizer alloc]initWithTarget: self action:@selector(handleCropAreaPinch:)];
        [_cropAreaView addGestureRecognizer: _cropAreaPinch];
    }
    else if( !needScaleCrop){
        [_cropAreaView removeGestureRecognizer: _cropAreaPinch];
        _cropAreaPinch = nil;
    }
    _needScaleCrop = needScaleCrop;
    
}
- (void)setCropAreaMidLineWidth:(CGFloat)cropAreaMidLineWidth {
    
    _cropAreaMidLineWidth = cropAreaMidLineWidth;
    _topMidLine.lineWidth = cropAreaMidLineWidth;
    _bottomMidLine.lineWidth = cropAreaMidLineWidth;
    _leftMidLine.lineWidth = cropAreaMidLineWidth;
    _rightMidLine.lineWidth = cropAreaMidLineWidth;
    if(_showMidLines) {
        [self resetMidLines];
    }
    
}
- (void)setCropAreaMidLineHeight:(CGFloat)cropAreaMidLineHeight {
    
    _cropAreaMidLineHeight = cropAreaMidLineHeight;
    _topMidLine.lineHeight = cropAreaMidLineHeight;
    _bottomMidLine.lineHeight = cropAreaMidLineHeight;
    _leftMidLine.lineHeight = cropAreaMidLineHeight;
    _rightMidLine.lineHeight = cropAreaMidLineHeight;
    if(_showMidLines) {
        [self resetMidLines];
    }
    
}
- (void)setCropAreaMidLineColor:(UIColor *)cropAreaMidLineColor {
    
    _cropAreaMidLineColor = cropAreaMidLineColor;
    _topMidLine.lineColor = cropAreaMidLineColor;
    _bottomMidLine.lineColor = cropAreaMidLineColor;
    _leftMidLine.lineColor = cropAreaMidLineColor;
    _rightMidLine.lineColor = cropAreaMidLineColor;
    
}
- (void)setCropAreaBorderLineWidth:(CGFloat)cropAreaBorderLineWidth {
    
    _cropAreaBorderLineWidth = cropAreaBorderLineWidth;
    _cropAreaView.borderWidth = cropAreaBorderLineWidth;
    [self resetCropAreaOnCornersFrameChanged];
    
}
- (void)setCropAreaBorderLineColor:(UIColor *)cropAreaBorderLineColor {
    
    _cropAreaBorderLineColor = cropAreaBorderLineColor;
    _cropAreaView.borderColor = cropAreaBorderLineColor;
    
}
- (void)setCropAreaCornerLineColor:(UIColor *)cropAreaCornerLineColor {
    
    _topLeftCorner.lineColor = cropAreaCornerLineColor;
    _topRightCorner.lineColor = cropAreaCornerLineColor;
    _bottomLeftCorner.lineColor = cropAreaCornerLineColor;
    _bottomRightCorner.lineColor = cropAreaCornerLineColor;
    
}
- (void)setCropAreaCornerLineWidth:(CGFloat)cropAreaCornerLineWidth {
    
    _cropAreaCornerLineWidth = cropAreaCornerLineWidth;
    _topLeftCorner.lineWidth = cropAreaCornerLineWidth;
    _topRightCorner.lineWidth = cropAreaCornerLineWidth;
    _bottomLeftCorner.lineWidth = cropAreaCornerLineWidth;
    _bottomRightCorner.lineWidth = cropAreaCornerLineWidth;
    [self resetCropAreaByAspectRatio];
    
}
- (void)setCropAreaCornerWidth:(CGFloat)cropAreaCornerWidth {
    
    _cropAreaCornerWidth = cropAreaCornerWidth;
    [self resetCornersOnSizeChanged];
    
}
- (void)setCropAreaCornerHeight:(CGFloat)cropAreaCornerHeight {
    
    _cropAreaCornerHeight = cropAreaCornerHeight;
    [self resetCornersOnSizeChanged];
    
}
- (void)setCropAspectRatio:(CGFloat)cropAspectRatio {
    
    _cropAspectRatio = MAX(cropAspectRatio, 0);
    [self resetCropAreaByAspectRatio];
    
}
- (void)setShowMidLines:(BOOL)showMidLines {
    
    if(_cropAspectRatio == 0) {
        if(!_showMidLines && showMidLines) {
            [self createMidLines];
            [self resetMidLines];
        }
        else if(_showMidLines && !showMidLines) {
            [self removeMidLines];
        }
    }
    _showMidLines = showMidLines;
    
}
- (void)setCornerBorderInImage:(BOOL)cornerBorderInImage {
    
    _cornerBorderInImage = cornerBorderInImage;
    [self resetCropAreaByAspectRatio];
    
}
- (void)setFrame:(CGRect)frame {
    
    [super setFrame: frame];
    [self resetImageView];
    
}
- (void)setCenter:(CGPoint)center {
    
    [super setCenter: center];
    [self resetImageView];
    
}

-(void)setMaskAlpha:(CGFloat)maskAlpha{
    _maskAlpha = maskAlpha;
    _cropMaskView.backgroundColor = self.configModel.layerBgColor ? self.configModel.layerBgColor : [UIColor colorWithRed:0 green:0 blue:0 alpha:_maskAlpha];
    _cropMaskView.alpha = _maskAlpha;
}
-(void)setShowInsideCropButton:(BOOL)showInsideCropButton{
    _showInsideCropButton = showInsideCropButton;
    [self resetCropAreaByAspectRatio];
}
-(void)setBtnCropWH:(CGFloat)btnCropWH{
    _btnCropWH = btnCropWH;
    [self resetCropButton];
}

#pragma mark - btn click
- (void)clickOkBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ImageViewFinish:)]) {
        [self.delegate ImageViewFinish:self.currentCroppedImage];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(ImageViewFinish:frame:)]) {
        [self.delegate ImageViewFinish:self.currentCroppedImage frame:self.cropAreaView.frame];
    }
}
- (void)clickCancelBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ImageViewCancel)]) {
        [self.delegate ImageViewCancel];
    }
}


#pragma mark - KVO CallBack
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if([object isEqual: _cropAreaView]) {
        if(_showMidLines){
            [self resetMidLines];
        }
        [self resetCropTransparentArea];
        return;
    }
    if([object isEqual: _imageView]) {
        [self resetCropAreaByAspectRatio];
    }
    
}
#pragma Instance Methods
- (UIImage *)currentCroppedImage {
    //根据图片和原始尺寸换算，得到最终截取图片
    CGFloat scaleFactor = WIDTH(_imageView) / _toCropImage.size.width;
    return [_toCropImage imageAtRect: CGRectMake((MINX(_cropAreaView) + _cropAreaBorderLineWidth) / scaleFactor, (MINY(_cropAreaView) + _cropAreaBorderLineWidth) / scaleFactor, (WIDTH(_cropAreaView) - 2 * _cropAreaBorderLineWidth) / scaleFactor, (HEIGHT(_cropAreaView) - 2 * _cropAreaBorderLineWidth) / scaleFactor)];
    
}



//最终的位置
-(CGRect)currentCroppedImageFrame{
    return self.cropAreaView.frame;
}
@end
