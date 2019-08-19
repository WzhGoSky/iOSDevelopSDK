//
//  DoodleBoardView.m
//  AFNetworking
//
//  Created by Hayder on 2019/2/22.
//


#import "DoodleBoardView.h"
#import "DoodleBoradViewTopHandleView.h"
#import "DoodleBoardViewBottomColorView.h"
#import "DoodleBoradViewBottomHandleView.h"
#import "DoodleDrawerView.h"
#import "globalDefine.h"
#import "ElectronicSignatureManager.h"
#import "UIColor+YYAdd.h"
#import "DrawingHelper.h"
#import "DoodleDrawerPaintPath.h"
#import "DoodleBoardClipHandleView.h"
#import "DoodleClipView.h"

@interface DoodleBoardView()<DoodleBoradViewTopHandleViewDelegate,DoodleBoardViewDelegate,UIGestureRecognizerDelegate,DoodleClipViewDelegate>

/**
 顶部操作栏
 */
@property (nonatomic, strong) DoodleBoradViewTopHandleView *topHandleView;

/**
 底部操作栏
 */
@property (nonatomic, strong) DoodleBoradViewBottomHandleView *bottomHandleView;

/**
 子项目栏
 */
@property (nonatomic, strong) DoodleBoardViewBottomColorView *subHandleView;

/**
 画板
 */
@property (nonatomic, strong) DoodleDrawerView *mainView;

/**
 会签
 */
@property (nonatomic, strong) UIImageView *waterImgView;

/**
 是否是涂鸦
 */
@property (nonatomic, assign) BOOL isEdit;

@property (nonatomic, strong) DoodleBoardConfig *config;

@property (nonatomic, assign) DoodleBoardHandleType currentType;

@property (nonatomic, strong) DoodleClipView *clipView;

/**
 需要编辑的图片
 */
@property (nonatomic, strong) UIImage *editImg;

@property (nonatomic, strong) UIImage *preImg;

@property (nonatomic, strong) void(^cancelBlock)(void);
@property (nonatomic, strong) void(^completeBlock)(UIImage *img);

/**
 编辑按钮
 */
@property (nonatomic, strong) UIButton *editBtn;

@end

@implementation DoodleBoardView

+(void)showDoodleBoardViewWithNeedEditImg:(UIImage *)img type:(DoodleBoardHandleType)type inView:(UIView *)superView cancelBlock:(void(^)(void))cancelBlock complete:(void(^)(UIImage *img))complete{
    
    DoodleBoardView *view = [[DoodleBoardView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    DoodleBoardConfig *config = [DoodleBoardConfig defaultConfigWithType:type delegate:view];
    view.config = config;
    view.cancelBlock = cancelBlock;
    view.completeBlock = complete;
    view.editImg = img;
    view.preImg = img;
    [superView addSubview:view];
}


+(void)showDoodleBoardViewWithNeedEditImg:(UIImage *)img type:(DoodleBoardHandleType)type cancelBlock:(void(^)(void))cancelBlock complete:(void(^)(UIImage *img))complete{
    
    [self showDoodleBoardViewWithNeedEditImg:img type:type inView:[UIApplication sharedApplication].keyWindow cancelBlock:cancelBlock complete:complete];
}

-(void)dealloc{
//    self.cropVc = nil;
    [self.mainView removeObserver:self forKeyPath:@"lines"];
    [self.mainView removeObserver:self forKeyPath:@"canUndoSex"];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.isEdit = YES;
        self.currentType = DoodleBoardHandleEidt;
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.mainView];
        [self addSubview:self.topHandleView];
        [self addSubview:self.bottomHandleView];
        [self addSubview:self.subHandleView];
        [self addSubview:self.editBtn];
        [self addSubview:self.clipView];
        //监听
        [self.mainView addObserver:self forKeyPath:@"lines" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
        [self.mainView addObserver:self forKeyPath:@"canUndoSex" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
        
        self.boardType = DoodleBoardViewEdit;

    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"lines"]) {
        
        BOOL state = self.mainView.lines.count > 0 ? YES : NO;
        self.subHandleView.undoState = state;
        
    }else if ([keyPath isEqualToString:@"canUndoSex"]){
        
        self.subHandleView.undoState = self.mainView.canUndoSex;
        
    }
}

#pragma DoodleBoradViewTopHandleViewDelegate
/**
 取消事件
 */
-(void)doodleBoradViewTopHandleViewDidCacnel:(UIButton *)btn{
    
    if (self.isHybrid) {
        [self editClick:self.editBtn];
    }else{
        __weak typeof(self)wself = self;
        [self dismissComplete:^{
            !wself.cancelBlock?:wself.cancelBlock();
        }];
    }
    
}

/**
 完成事件
 */
-(void)doodleBoradViewTopHandleViewDidFinfish:(UIButton *)btn{
    
    if (self.isHybrid) {
        !self.completeBlock?:self.completeBlock([self getEidtingImg]);
        [self editClick:self.editBtn];
    }else{
        __weak typeof(self)wself = self;
        [self dismissComplete:^{
            !wself.completeBlock?:wself.completeBlock([wself getEidtingImg]);
        }];
    }
}

#pragma DoodleBoardViewDelegate
/**
 编辑
 */
-(void)DoodleBoardViewDidClickEdit{
    self.waterImgView.userInteractionEnabled = YES;
    self.mainView.type = DoodleDrawerViewNormal;
    self.mainView.canDrawer = YES;
    self.subHandleView.handeDatas = [self.config getBottomHandleSubDatasWithType:DoodleBoardBottomHandleEidt];
    self.subHandleView.undoState = self.mainView.lines.count > 0 ? YES : NO;
    [self showSubItemViewWithType:DoodleBoardHandleEidt];
}

/**
 会签
 */
-(void)DoodleBoardViewDidClickSignature{
    self.waterImgView.userInteractionEnabled = YES;
    self.subHandleView.handeDatas = [self.config getBottomHandleSubDatasWithType:DoodleBoardBottomHandleSignature];
     [self showSubItemViewWithType:DoodleBoardHandleSignature];
    [ElectronicSignatureManager showElectronicSignatureViewWithConfig:[ElectronicSignatureConfig defaultConfig] complete:^(UIImage *img, CGRect frame) {
        if (img) {
            [self.waterImgView removeFromSuperview];
            self.waterImgView = nil;
            
            self.mainView.canDrawer = NO;
            self.waterImgView.image = img;
            self.waterImgView.frame = frame;
            [self.mainView addSubview:self.waterImgView];
            [self.mainView bringSubviewToFront:self.waterImgView];
        }
    } superViewFrame:self.mainView.frame];
}

/**
 马塞克
 */
-(void)DoodleBoardViewDidClickCode{
    self.waterImgView.userInteractionEnabled = NO;
    self.mainView.type = DoodleDrawerViewSex;
    self.subHandleView.handeDatas = [self.config getBottomHandleSubDatasWithType:DoodleBoardBottomHandleCode];
    self.subHandleView.undoState = self.mainView.canUndoSex;
    [self showSubItemViewWithType:DoodleBoardHandleCode];
}

/**
 裁剪
 */
-(void)DoodleBoardViewDidClickTailoring{
    
    self.waterImgView.userInteractionEnabled = YES;
    self.subHandleView.handeDatas = [self.config getBottomHandleSubDatasWithType:DoodleBoardBottomHandleTailoring];
    [self showSubItemViewWithType:DoodleBoardHandleTailoring];
    
//    self.cropVc = nil;
    
    [self.mainView hiddenLayer];
    
    self.clipView.hidden = NO;
    self.clipView.toCropImage = self.editImg;
    [self bringSubviewToFront:self.clipView];
    
//    [DoodleBoardClipView showDoodleBoardClipHandleViewWithImg:self.editImg preImg:self.preImg superView:self cancleBlock:^{
//
//    } complete:^(UIImage * _Nonnull img) {
//        self.editImg = img;
//        [self.mainView refreshSexImg];
//        if (self.waterImgView) {
//
//            self.waterImgView.hidden = NO;
//            [self.waterImgView removeFromSuperview];
//
//            [self.mainView addSubview:self.waterImgView];
//            [self.mainView bringSubviewToFront:self.waterImgView];
//        }
//    }];
    
//    if (!self.cropVc) {
//
//        if (self.waterImgView) {
//            [self.waterImgView removeFromSuperview];
//            [[UIApplication sharedApplication].keyWindow addSubview:self.waterImgView];
//            [[UIApplication sharedApplication].keyWindow  bringSubviewToFront:self.waterImgView];
//        }
//
//
//
//        self.cropVc = [[TOCropViewController alloc]initWithImage:img];
//        self.cropVc.delegate = self;
//
//    }else{
//
//        if (self.waterImgView) {
//            [self.waterImgView removeFromSuperview];
//            [[UIApplication sharedApplication].keyWindow  addSubview:self.waterImgView];
//            [[UIApplication sharedApplication].keyWindow  bringSubviewToFront:self.waterImgView];
//        }
//    }
//
//    UIViewController *vc = [NSObject getCurrentController] ? [NSObject getCurrentController] : [UIApplication sharedApplication].keyWindow.rootViewController;
//
//    [self.cropVc presentAnimatedFromParentViewController:vc fromImage:self.editImg fromView:self fromFrame:[UIScreen mainScreen].bounds angle:self.angle toImageFrame:self.croppedFrame setup:^{
//        self.waterImgView.hidden = YES;
//    } completion:^{
//        [[UIApplication sharedApplication].keyWindow addSubview:self.cropVc.view];
//        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.cropVc.view];
//    }];
    
    
}

#pragma DoodleClipViewDelegate
- (void)ImageViewFinish:(UIImage *)cropImage{
    self.clipView.hidden = YES;
    
    self.editImg = cropImage;
    [self.mainView refreshSexImg];
    if (self.waterImgView) {
        self.waterImgView.hidden = NO;
        [self.waterImgView removeFromSuperview];

        [self.mainView addSubview:self.waterImgView];
        [self.mainView bringSubviewToFront:self.waterImgView];
    }
    !self.completeBlock?:self.completeBlock(cropImage);
}

- (void)ImageViewCancel{
    self.clipView.hidden = YES;
    !self.cancelBlock?:self.cancelBlock();
}

/**
 点击颜色
 */
-(void)DoodleBoardViewDidChooseColor:(NSString *)color{
    NSString *colorStr = [NSString stringWithFormat:@"#%@",color];
    self.mainView.lineColor = [UIColor colorWithHexString:colorStr];
}

/**
 撤销
 */
-(void)DoodleBoardViewDidClickUndo:(DoodleBoardBottomHandleType)type{
    if (type == DoodleBoardBottomHandleEidt) {
        [self.mainView undo];
    }else if (type == DoodleBoardBottomHandleCode){
        [self.mainView clearSex];
    }else if (type == DoodleBoardBottomHandleSignature){
        [self.waterImgView removeFromSuperview];
        self.waterImgView = nil;
    }
}

#pragma TOCropViewControllerDelegate
//- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
//{
//    self.croppedFrame = cropRect;
//    self.angle = angle;
//    [self updateImageViewWithImage:image fromCropViewController:cropViewController rect:cropRect];
//}
//
//- (void)cropViewController:(TOCropViewController *)cropViewController didCropToCircularImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
//{
//    self.croppedFrame = cropRect;
//    self.angle = angle;
//    [self updateImageViewWithImage:image fromCropViewController:cropViewController rect:cropRect];
//}
//
//- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(TOCropViewController *)cropViewController rect:(CGRect)rect
//{
//    self.isEdit = YES;
//
//    [self.mainView showLayer];
//
//    [self.mainView refreshPathWithOldFrame:self.mainView.frame newFrame:rect];
//
//    if (cropViewController.croppingStyle != TOCropViewCroppingStyleCircular) {
//        [cropViewController dismissAnimatedFromParentViewController:[NSObject getCurrentController] withCroppedImage:image toView:self toFrame:CGRectZero setup:^{
//            self.editImg = image;
//            [self.mainView refreshSexImg];
//        } completion:^{
//            self.cropVc = nil;
////            [self.waterImgView removeFromSuperview];
////            self.waterImgView = nil;
//
//            if (self.waterImgView) {
//                if (CGRectIntersectsRect(rect, self.waterImgView.frame)) {
//
//                    self.waterImgView.hidden = NO;
//                    [self.waterImgView removeFromSuperview];
//
//                    CGRect frame = self.waterImgView.frame;
//                    frame.origin.y -= rect.origin.y;
//                    self.waterImgView.frame = frame;
//
//                    [self.mainView addSubview:self.waterImgView];
//                    [self.mainView bringSubviewToFront:self.waterImgView];
//
//                }else{
//                    [self.waterImgView removeFromSuperview];
//                    self.waterImgView = nil;
//                }
//            }
//        }];
//    }else {
//        [cropViewController dismissViewControllerAnimated:YES completion:nil];
//        self.cropVc = nil;
//    }
//}


//- (void)cropViewController:(nonnull TOCropViewController *)cropViewController
//        didFinishCancelled:(BOOL)cancelled{
//    [cropViewController dismissAnimatedFromParentViewController:[NSObject getCurrentController] toView:self toFrame:CGRectZero setup:^{
//
//    } completion:^{
//        self.cropVc = nil;
//    }];
//}

-(void)showSubItemViewWithType:(DoodleBoardHandleType)type{
    
    if (self.subHandleView.handeDatas.count > 0) {
        self.subHandleView.hidden = NO;
        self.subHandleView.alpha = 1;
        return;
    }
    
    self.subHandleView.alpha = (1 - self.subHandleView.alpha);
    self.subHandleView.hidden = !self.subHandleView.hidden;
    [UIView animateWithDuration:0.2 animations:^{
        self.subHandleView.alpha = (1 - self.subHandleView.alpha);
    } completion:^(BOOL finished) {
        self.currentType = type;
    }];
}


-(UIImage *)getEidtingImg{
    return [self.mainView getEidtImg];
}

- (void)dismissComplete:(void(^)(void))complete{
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         CGRect frame = self.frame;
                         frame.origin.y += frame.size.height ;
                         [self setFrame:frame];
                         
                     }
                     completion:^(BOOL finished) {
                         
                         !complete?:complete();
                         [self.mainView.canceledLines removeAllObjects];
                         [self.mainView.lines removeAllObjects];
                     }];
}

#pragma 会签
-(void)pan:(UIPanGestureRecognizer *)pan{
    CGPoint point = [pan translationInView:pan.view];
    CGPoint temp = self.waterImgView.center;
    temp.x += point.x * (self.waterImgView.frame.size.width / 100.0 * 0.5);
    temp.y += point.y * (self.waterImgView.frame.size.height / 100.0 * 0.5);
    self.waterImgView.center = temp;
    [pan setTranslation:CGPointZero inView:pan.view];
}

-(void)rotationView:(UIRotationGestureRecognizer *)gesture{
    self.waterImgView.transform = CGAffineTransformRotate(self.waterImgView.transform, gesture.rotation);
    gesture.rotation = 0;
}

-(void)pinch:(UIPinchGestureRecognizer *)pinch{
    self.waterImgView.transform = CGAffineTransformScale(self.waterImgView.transform, pinch.scale, pinch.scale);
    pinch.scale = 1.0;
}

-(void)setEditImg:(UIImage *)editImg{
    _editImg = editImg;
    
    self.mainView.frame =  [self drawImageRectWithImage:editImg];
    self.mainView.image =  [DrawingHelper drawImgWithImg:editImg rect:self.mainView.frame];;
    
    [self setNeedsLayout];
}

-(void)editClick:(UIButton *)btn{
    self.boardType = (self.boardType == DoodleBoardViewNormal ? DoodleBoardViewEdit : DoodleBoardViewNormal);
    !self.stateChangeBlock?:self.stateChangeBlock(self.boardType == DoodleBoardViewNormal ? YES : NO);
}

#pragma lazy
-(void)setBoardType:(DoodleBoardViewType)boardType{
    _boardType = boardType;
    
    self.editBtn.hidden = (boardType != DoodleBoardViewNormal);
    
    self.topHandleView.hidden = !self.editBtn.hidden;
    self.bottomHandleView.hidden = !self.editBtn.hidden;
    self.subHandleView.hidden = !self.editBtn.hidden;
    
    self.mainView.userInteractionEnabled = self.editBtn.hidden;
}

-(void)setConfig:(DoodleBoardConfig *)config{
    _config = config;
    self.bottomHandleView.handlDatas = [config getBottomHandleDatas];
    self.subHandleView.handeDatas = [config getBottomHandleSubDatasWithType:DoodleBoardBottomHandleEidt];
}

-(DoodleBoradViewTopHandleView *)topHandleView{
    if (!_topHandleView) {
        _topHandleView = [[DoodleBoradViewTopHandleView alloc]initWithFrame:CGRectMake(0, 44, self.frame.size.width, 44)];
        _topHandleView.delegate = self;
    }
    return _topHandleView;
}

-(DoodleBoradViewBottomHandleView *)bottomHandleView{
    if (!_bottomHandleView) {
        _bottomHandleView = [[DoodleBoradViewBottomHandleView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 20 - 44, self.frame.size.width, 44)];
    }
    return _bottomHandleView;
}

-(DoodleBoardViewBottomColorView *)subHandleView{
    if (!_subHandleView) {
        _subHandleView = [[DoodleBoardViewBottomColorView alloc]initWithFrame:CGRectMake(0, self.bottomHandleView.frame.origin.y - 44, self.frame.size.width, 44)];
    }
    return _subHandleView;
}

-(DoodleClipView *)clipView{
    if (!_clipView) {
        _clipView = [[DoodleClipView alloc]initWithFrame:self.bounds];
        _clipView.needScaleCrop = YES;           //允许手指捏和缩放裁剪框
        _clipView.showInsideCropButton = YES;    //允许内部裁剪按钮
        _clipView.btnCropWH = 30;                //内部裁剪按钮宽高，有默认值，不设也没事
        _clipView.delegate = self;               //需要实现内部裁剪代理事件
        _clipView.hidden = YES;
    }
    return _clipView;
}


-(DoodleDrawerView *)mainView{
    if (!_mainView) {
        _mainView = [[DoodleDrawerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _mainView.contentMode = UIViewContentModeScaleAspectFill;
        _mainView.layer.backgroundColor = [UIColor clearColor].CGColor;
        _mainView.type = DoodleDrawerViewNormal;
        _mainView.layer.masksToBounds = YES;
        _mainView.lineColor = [UIColor redColor];
    }
    return _mainView;
}

-(UIImageView *)waterImgView{
    if (!_waterImgView) {
        _waterImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        _waterImgView.contentMode = UIViewContentModeScaleAspectFit;
        _waterImgView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [_waterImgView addGestureRecognizer:pan];
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
        pinch.delegate = self;
        [_waterImgView addGestureRecognizer:pinch];
        
    }
    return _waterImgView;
}


- (CGRect)drawImageRectWithImage:(UIImage *)image
{
    CGSize imageSize = image.size;
    CGRect imageRect;
    
    if ((imageSize.width > 0) && (imageSize.height > 0)){
        
        float ratioW = self.bounds.size.width/imageSize.width;
        float ratioH = self.bounds.size.height/imageSize.height;
        float ratio = MIN(ratioW, ratioH);
        
        imageSize = CGSizeMake((int)(imageSize.width*ratio), (int)(imageSize.height*ratio));
        
        imageRect.size = imageSize;
        imageRect.origin.x = (int)(self.bounds.size.width/2-imageSize.width/2);
        imageRect.origin.y = (int)(SCREEN_HEIGHT/2-imageSize.height/2);
    }
    return imageRect;
}


-(UIButton *)editBtn{
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat btnW = 80;
        
        _editBtn.frame = CGRectMake((SCREEN_WIDTH - btnW) * 0.5, SCREEN_HEIGHT - 44 - 20, btnW, 25);
        
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [_editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _editBtn.backgroundColor = [UIColor lightGrayColor];
        _editBtn.alpha = 0.8;
        _editBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_editBtn addTarget:self action:@selector(editClick:) forControlEvents:UIControlEventTouchUpInside];
        _editBtn.layer.cornerRadius = 5.0f;
        _editBtn.layer.masksToBounds = YES;
        
    }
    return _editBtn;
}

@end

@interface DoodleBoardViewCell()
@property (nonatomic, strong) DoodleBoardView *mainView;
@end


@implementation DoodleBoardViewCell

-(void)setModel:(DrawingModel *)model{
    _model = model;
    self.mainView.editImg = model.img;
}

-(void)setType:(DoodleBoardHandleType)type{
    _type = type;
    DoodleBoardConfig *config = [DoodleBoardConfig defaultConfigWithType:type delegate:self.mainView];
    self.mainView.config = config;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.mainView.frame = [UIScreen mainScreen].bounds;
}

-(void)setBoardType:(DoodleBoardViewType)boardType{
    _boardType = boardType;
    self.mainView.boardType = boardType;
}

-(DoodleBoardView *)mainView{
    if (!_mainView) {
        __weak typeof(self)wself = self;
        _mainView = [[DoodleBoardView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _mainView.boardType = DoodleBoardViewEdit;
        _mainView.cancelBlock = ^{
            
        };
        _mainView.completeBlock = ^(UIImage *img) {
            if (img) {
                NSString *locImgPath = [DrawingHelper saveImage:img andName:@"Edit"];
                UIImage *locImg = [DrawingHelper readImageWithName:locImgPath];
                if (locImg) {
                    wself.model.img = locImg;
                }else{
                    wself.model.img = img;
                }
            }
        };
        _mainView.stateChangeBlock = ^(BOOL isNoraml) {
            if ([wself.delegate respondsToSelector:@selector(DoodleBoardViewCellDidChangeState:)]) {
                [wself.delegate DoodleBoardViewCellDidChangeState:isNoraml];
            }
        };
        [self.contentView addSubview:_mainView];
    }
    return _mainView;
}

-(void)setIsHybrid:(BOOL)isHybrid{
    _isHybrid = isHybrid;
    self.mainView.isHybrid = isHybrid;
}

@end
