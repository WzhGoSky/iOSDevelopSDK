//
//  ImageShowView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/21.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "ImageShowView.h"
#import "ImageShowDeitalView.h"
#import "ImageShowModel.h"
#import "ImageShowConfigManager.h"
#import "ImageShowToolManager.h"
#import "ImageShowTopHandleView.h"
#import "ImageShowToolManager.h"
#import "ImageShowHelper.h"
#import "globalDefine.h"
#import <SDWebImage/SDWebImage.h>
/*
 1.显示影藏：可追踪位置
 2.数据： 支持图片+ 长图 + gif图片 + 短视频
 3.UI
 1.滚动方向
 2.图片缩放
 3.资源下载
 */
@interface ImageShowView()<UICollectionViewDelegate,UICollectionViewDataSource,ImageShowDeitalViewDelegate,ImageShowViewHandleDelegate,ImageShowTopHandleViewDelegate>

@property (nonatomic, assign) ShowImageMangerType alertType;

@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) UICollectionView *mainView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

@property (nonatomic, strong) ImageShowModel *currentModel;

@property (nonatomic, strong) ImageShowTopHandleView *topView;

@property (nonatomic, strong) UIButton *downLoadBtn;

@property (nonatomic, strong) UILabel *iconTitleLabel;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, assign) BOOL showHandle;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) UIButton *originalBtn;

@property (nonatomic, strong) void(^shareClickBlock)(UIImage *icon, NSString *dataUrl);
@property (nonatomic, strong) void(^shareBlock)(ImageShowModel *model);

@property (nonatomic, strong) void(^currentInfoBlock)(NSInteger index, ImageShowModel *model);

//dismissBlock
@property (nonatomic, strong) void(^dismissBlock)(void);

@end

@implementation ImageShowView

-(instancetype)initWithFrame:(CGRect)frame withScrollDirection:(UICollectionViewScrollDirection)scrollDirection bottomView:(UIView *)bottomView{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIPanGestureRecognizer *down = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(downAction:)];
        [self addGestureRecognizer:down];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        [self addGestureRecognizer:tap];
        
        self.scrollDirection = scrollDirection;
        self.backgroundColor = [UIColor blackColor];
        
        [self addSubview:self.mainView];
        [self addSubview:self.topView];
        [self addSubview:self.downLoadBtn];
        [self addSubview:self.iconTitleLabel];
        [self addSubview:self.originalBtn];
        
        self.bottomView = bottomView;
        [self addSubview:bottomView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playCurrentVideo) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(puaseCurrentVideo) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)playCurrentVideo{
    
    //    //获取当前显示的cell
    ImageShowDeitalViewCell *cellItem = [self.mainView visibleCells].lastObject;
    [cellItem play];
}

-(void)puaseCurrentVideo{
    //    //获取当前显示的cell
    ImageShowDeitalViewCell *cellItem = [self.mainView visibleCells].lastObject;
    [cellItem pause];
}

+(void)dismiss{
    for (UIView *subView in [UIApplication sharedApplication].keyWindow.subviews) {
        if ([subView isKindOfClass:[self class]]) {
            [subView removeFromSuperview];
        }
    }
}

+(void)dismissInSuperView:(UIView *)view{
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[self class]]) {
            [subView removeFromSuperview];
        }
    }
}

/**
 图片浏览器
 datas: 数据源，数据模型必须实现指定协议方法
 shareBlock: 如果有配置分享事件， 则改通过block 返回资源
 */
#pragma  -------
//
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas indexPath:(NSInteger)index shareModelBlock:(void(^)(ImageShowModel *model))shareBlock{
        [self showImageBrowsingWithModelDatas:datas LongPressAlertType:(ShowImageMangerTypeOriginalImage | ShowImageMangerTypeDownLoadImg | ShowImageMangerTypeEdit | ShowImageMangerTypeShare) scrollDirection:UICollectionViewScrollDirectionHorizontal inView:[UIApplication sharedApplication].keyWindow toIndexPath:index bottomView:nil shareModelBlock:shareBlock];
}
//
+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas indexPath:(NSInteger)index shareModelBlock:(void(^)(ImageShowModel *model))shareBlock{
    [self showImageBrowsingWithDatas:datas LongPressAlertType:(ShowImageMangerTypeOriginalImage | ShowImageMangerTypeDownLoadImg | ShowImageMangerTypeEdit | ShowImageMangerTypeShare) scrollDirection:UICollectionViewScrollDirectionHorizontal inView:[UIApplication sharedApplication].keyWindow toIndexPath:index bottomView:nil shareModelBlock:shareBlock];
}

#pragma  -------
//
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas indexPath:(NSInteger)index shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock{
    [self showImageBrowsingWithModelDatas:datas LongPressAlertType:(ShowImageMangerTypeOriginalImage | ShowImageMangerTypeDownLoadImg | ShowImageMangerTypeEdit | ShowImageMangerTypeShare)  scrollDirection:UICollectionViewScrollDirectionHorizontal inView:[UIApplication sharedApplication].keyWindow toIndexPath:index bottomView:nil shareModelBlock:shareBlock currentBlock:currentBlock];
}
//
+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas indexPath:(NSInteger)index shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock{
    [self showImageBrowsingWithDatas:datas LongPressAlertType:(ShowImageMangerTypeOriginalImage | ShowImageMangerTypeDownLoadImg | ShowImageMangerTypeEdit | ShowImageMangerTypeShare) scrollDirection:UICollectionViewScrollDirectionHorizontal inView:[UIApplication sharedApplication].keyWindow toIndexPath:index bottomView:nil shareModelBlock:shareBlock currentBlock:currentBlock];
}



#pragma  -------
//
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas indexPath:(NSInteger)index inView:(UIView *)inView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock
{
     [self showImageBrowsingWithModelDatas:datas LongPressAlertType:(ShowImageMangerTypeOriginalImage | ShowImageMangerTypeDownLoadImg | ShowImageMangerTypeEdit | ShowImageMangerTypeShare) scrollDirection:UICollectionViewScrollDirectionHorizontal inView:inView toIndexPath:index bottomView:nil shareModelBlock:shareBlock];
}
//
+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas indexPath:(NSInteger)index inView:(UIView *)inView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock
{
    [self showImageBrowsingWithDatas:datas LongPressAlertType:(ShowImageMangerTypeOriginalImage | ShowImageMangerTypeDownLoadImg | ShowImageMangerTypeEdit | ShowImageMangerTypeShare) scrollDirection:UICollectionViewScrollDirectionHorizontal inView:inView toIndexPath:index bottomView:nil shareModelBlock:shareBlock];
}
//
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas indexPath:(NSInteger)index inView:(UIView *)inView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock{
    
    [self showImageBrowsingWithModelDatas:datas LongPressAlertType:(ShowImageMangerTypeOriginalImage | ShowImageMangerTypeDownLoadImg | ShowImageMangerTypeEdit | ShowImageMangerTypeShare) scrollDirection:UICollectionViewScrollDirectionHorizontal inView:inView toIndexPath:index bottomView:nil shareModelBlock:shareBlock currentBlock:currentBlock];
}
//
+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas indexPath:(NSInteger)index inView:(UIView *)inView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock{
    
    [self showImageBrowsingWithDatas:datas LongPressAlertType:(ShowImageMangerTypeOriginalImage | ShowImageMangerTypeDownLoadImg | ShowImageMangerTypeEdit | ShowImageMangerTypeShare) scrollDirection:UICollectionViewScrollDirectionHorizontal inView:inView toIndexPath:index bottomView:nil shareModelBlock:shareBlock currentBlock:currentBlock];
}
#pragma  -------
//
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas LongPressAlertType:(ShowImageMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index bottomView:(UIView *)bottomView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock{
    ImageShowView *mainView = [[ImageShowView alloc]initWithFrame:[UIScreen mainScreen].bounds withScrollDirection:scrollDirection bottomView:bottomView];
    mainView.alertType = type;
    mainView.currentIndex = index;
    mainView.datas = datas;
    [mainView.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    mainView.shareBlock = shareBlock;
    [view addSubview:mainView];
    [view bringSubviewToFront:mainView];
}

//
+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas LongPressAlertType:(ShowImageMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index bottomView:(UIView *)bottomView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock{
    ImageShowView *mainView = [[ImageShowView alloc]initWithFrame:[UIScreen mainScreen].bounds withScrollDirection:scrollDirection bottomView:bottomView];
    mainView.alertType = type;
    mainView.currentIndex = index;
    mainView.datas = datas;
    [mainView.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]  atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    mainView.shareBlock = shareBlock;
    [view addSubview:mainView];
    [view bringSubviewToFront:mainView];
}
#pragma  -------

+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas LongPressAlertType:(ShowImageMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index bottomView:(UIView *)bottomView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock{
    ImageShowView *mainView = [[ImageShowView alloc]initWithFrame:[UIScreen mainScreen].bounds withScrollDirection:scrollDirection bottomView:bottomView];
    mainView.alertType = type;
    mainView.currentInfoBlock = currentBlock;
    mainView.currentIndex = index;
    mainView.datas = datas;
    [mainView.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]  atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    mainView.shareBlock = shareBlock;
    [view addSubview:mainView];
    [view bringSubviewToFront:mainView];
}

+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas LongPressAlertType:(ShowImageMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index bottomView:(UIView *)bottomView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock dismissBlock:(void(^)(void))dismissBlock{
    ImageShowView *mainView = [[ImageShowView alloc]initWithFrame:[UIScreen mainScreen].bounds withScrollDirection:scrollDirection bottomView:bottomView];
    mainView.alertType = type;
    mainView.dismissBlock = dismissBlock;
    mainView.currentInfoBlock = currentBlock;
    mainView.currentIndex = index;
    mainView.datas = datas;
    [mainView.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]  atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    mainView.shareBlock = shareBlock;
    [view addSubview:mainView];
    [view bringSubviewToFront:mainView];
}

+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas LongPressAlertType:(ShowImageMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index bottomView:(UIView *)bottomView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock{
    ImageShowView *mainView = [[ImageShowView alloc]initWithFrame:[UIScreen mainScreen].bounds withScrollDirection:scrollDirection bottomView:bottomView];
    mainView.alertType = type;
    mainView.currentInfoBlock = currentBlock;
    mainView.currentIndex = index;
    mainView.datas = datas;
    [mainView.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    mainView.shareBlock = shareBlock;
    [view addSubview:mainView];
    [view bringSubviewToFront:mainView];
}
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas LongPressAlertType:(ShowImageMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index bottomView:(UIView *)bottomView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock dismissBlock:(void(^)(void))dismissBlock{
    ImageShowView *mainView = [[ImageShowView alloc]initWithFrame:[UIScreen mainScreen].bounds withScrollDirection:scrollDirection bottomView:bottomView];
    mainView.alertType = type;
    mainView.dismissBlock = dismissBlock;
    mainView.currentInfoBlock = currentBlock;
    mainView.currentIndex = index;
    mainView.datas = datas;
    [mainView.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    mainView.shareBlock = shareBlock;
    [view addSubview:mainView];
    [view bringSubviewToFront:mainView];
}

/**
 获取当前显示的图片浏览器
 返回值可能为空
 */
+(instancetype)getCurrentShowView{
    return [self getCurrentShowWithSuperView:[UIApplication sharedApplication].keyWindow];
}
+(instancetype)getCurrentShowWithSuperView:(UIView *)superView{
    ImageShowView *view = nil;
    for (UIView *subView in superView.subviews) {
        if ([subView isKindOfClass:[self class]]) {
            view = (ImageShowView *)subView;
            break;
        }
    }
    return view;
}

/**
 编辑方法
 */
-(void)evokeEdit{
    [self ImageShowViewShowEditImg];
}

/**
 下载
 */
-(void)evokeDownLoad{
    [self ImageShowViewShowDownLoadImg];
}

/**
 查看原图
 */
-(void)evokeShowOriginal{
    [self originalImg:nil];
}

/**
 分享
 */
-(ImageShowModel *)evokeShare{
    
    return self.currentModel;
}

/**
 删除指定数据源图片
 */
-(void)deleteModel:(ImageShowModel *)model{
    if (!model) {return;}
    NSInteger index = 0;
    if ([self.datas containsObject:model]) {
        index = (NSInteger)[self.datas indexOfObject:model];
        [self.datas removeObject:model];
    }else{
        ImageShowModel *deleteModel = nil;
        for (ImageShowModel *subModel in self.datas) {
            if ([subModel.imageUrlStr isEqualToString:model.imageUrlStr]) {
                deleteModel = subModel;
                break;
            }
        }
        if (deleteModel) {
            index = (NSInteger)[self.datas indexOfObject:deleteModel];
            [self.datas removeObject:deleteModel];
        }
    }

    NSMutableArray *temp = [self.datas mutableCopy];
    self.datas = temp;
    [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]  atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}


-(void)setDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas{
    
    if (datas.count == 0) {return;}
    
    NSMutableArray *temp = [NSMutableArray array];
    for (id<ImageShowViewDelegate> subData in datas) {
        ImageShowModel *model = nil;
        
        if (![subData isKindOfClass:[ImageShowModel class]]) {
                model = [[ImageShowModel alloc]init];
            if ([subData respondsToSelector:@selector(ImageShowViewImageUrl)]) {
                model.imageUrlStr = [subData ImageShowViewImageUrl];
            }
            if ([subData respondsToSelector:@selector(ImageShowViewOriginalImageUrl)]) {
                model.originUrlStr = [subData ImageShowViewOriginalImageUrl];
                model.isOrigin =  model.originUrlStr.length;
            }
            if ([subData respondsToSelector:@selector(ImageShowViewVideoUrl)]) {
                model.viodeUrlStr = [subData ImageShowViewVideoUrl];
                model.isVideo = model.viodeUrlStr.length;
            }
            if ([subData respondsToSelector:@selector(ImageShowViewImageWidth)]) {
                model.imgWidth = [subData ImageShowViewImageWidth];
            }
            if ([subData respondsToSelector:@selector(ImageShowViewImageHeight)]) {
                model.imgHeight = [subData ImageShowViewImageHeight];
            }
            
            if ([subData respondsToSelector:@selector(ImageShowViewImageDes)]) {
                if (!model.isVideo) {                
                    model.iconDes = [subData ImageShowViewImageDes];
                }
            }
            
            if ([subData respondsToSelector:@selector(ImageShowViewImage)]) {
                model.img = [subData ImageShowViewImage];
            }
            
            
            if ([subData respondsToSelector:@selector(ImageShowViewImageVideoTime)]) {
                model.videoTime = [subData ImageShowViewImageVideoTime];
            }
        }else{
            model = (ImageShowModel *)subData;
        }
        
        [temp addObject:model];
    }

    _datas = temp;
    self.topView.totalCount = temp.count;
    __block ImageShowModel *firstModel = temp[self.currentIndex];
    self.currentModel = firstModel;
    
    //如果是第一张图片。下载图片
    if (!firstModel.img) {
        NSString *imgUrl = firstModel.isOrigin ? firstModel.originUrlStr : firstModel.imageUrlStr;
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imgUrl] options:SDWebImageProgressiveLoad progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            firstModel.img = image;
            !self.currentInfoBlock?:self.currentInfoBlock(self.currentIndex,self.currentModel);
        }];
    }else{
         !self.currentInfoBlock?:self.currentInfoBlock(self.currentIndex,self.currentModel);
    }
    
    self.topView.isVideo = firstModel.isVideo;
    self.iconTitleLabel.text = firstModel.iconDes;
    self.iconTitleLabel.hidden = !firstModel.iconDes.length;
    [self refreshDownLoad];
    
    [self.mainView reloadData];
}

#pragma ImageShowDeitalViewDelegate
-(void)ImageShowDeitalViewDidDismiss{
    //    //获取当前显示的cell
    ImageShowDeitalViewCell *cellItem = [self.mainView visibleCells].lastObject;
    
    self.showHandle = !self.showHandle;
    if (self.showHandle) {
        CGFloat top = 0;
        if (KIsiPhoneX) {
            top = 10;
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.originalBtn.transform = CGAffineTransformMakeTranslation(0, self.bottomView.frame.size.height);
            self.topView.transform = CGAffineTransformMakeTranslation(0, - (self.topView.frame.size.height + top));
            self.downLoadBtn.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height - CGRectGetMaxY(self.downLoadBtn.frame) + self.downLoadBtn.frame.size.height);
            self.iconTitleLabel.transform = CGAffineTransformMakeTranslation(0,  self.bottomView.frame.size.height);
            cellItem.originalBtnTransFromY = 0;
            if (self.bottomView != nil) {
                self.bottomView.transform = CGAffineTransformMakeTranslation(0, self.bottomView.frame.size.height);
            }
        }];
      
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            self.originalBtn.transform = CGAffineTransformIdentity;
            self.topView.transform = CGAffineTransformIdentity;
            self.downLoadBtn.transform = CGAffineTransformIdentity;
            self.iconTitleLabel.transform = CGAffineTransformIdentity;
            cellItem.originalBtnTransFromY = self.bottomView.frame.size.height;
            if (self.bottomView != nil) {
                self.bottomView.transform = CGAffineTransformIdentity;
            }
        }];
    }
}
/**
 返回
 */
-(void)ImageShowDeitalViewDidClickBack{
    
//    !self.dismissBlock?:self.dismissBlock();
    [self removeFromSuperview];
}

/**
 隐藏
 */
-(void)downAction:(UIPanGestureRecognizer *)tap{
    //在 x 轴上面滑动的距离
    CGFloat tx = [tap translationInView:self].x;
    //在 y 轴上面滑动的距离
    CGFloat ty = [tap translationInView:self].y;
    CGFloat scale = 1 - fabs(ty / (CGFloat)[UIScreen mainScreen].bounds.size.height);
    scale = scale < 0 ? 0 : scale;
    
    [self dismissAnimationWithTransformX:tx transformY:ty scale:scale tap:tap cell:nil];
}


/**
 长度隐藏
 */
-(void)ImageShowDeitalViewLongPictureWillDismissTransformY:(CGFloat)transformy scale:(CGFloat)scale{
    //    //获取当前显示的cell
    ImageShowDeitalViewCell *cellItem = [self.mainView visibleCells].lastObject;
    [self dismissAnimationWithTransformX:0 transformY:transformy scale:scale tap:nil cell:cellItem];
}

-(void)dismissAnimationWithTransformX:(CGFloat)tx transformY:(CGFloat)ty scale:(CGFloat)scale tap:(UIPanGestureRecognizer *)tap cell:(ImageShowDeitalViewCell *)cell{
    if (!tap) {
        [cell hiddenLongVerticalView:NO];
        if (scale > 0.25) {
            
            !self.dismissBlock?:self.dismissBlock();
            [self removeFromSuperview];
            
        }else{
        }
//        self.mainView.transform = CGAffineTransformMake( 1 - scale, 0, 0, 1 - scale, tx, ty);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha: 1 - scale];
        return;
    }
    
    if (tap.state == UIGestureRecognizerStateEnded || tap.state == UIGestureRecognizerStateRecognized) {
        if ([tap velocityInView:self].y > 0) {
            
            !self.dismissBlock?:self.dismissBlock();
            [self removeFromSuperview];
        }else{
            [UIView animateWithDuration:0.5 animations:^{
                self.mainView.transform = CGAffineTransformIdentity;
                self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
            }];
        }
    }else if (tap.state == UIGestureRecognizerStateEnded || tap.state == UIGestureRecognizerStateFailed ){
        [UIView animateWithDuration:0.5 animations:^{
            self.mainView.transform = CGAffineTransformIdentity;
            self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        }];
    }else{
        if (scale < 0.2) {
            
            !self.dismissBlock?:self.dismissBlock();
            [self removeFromSuperview];
        }else{
        }
        self.mainView.transform = CGAffineTransformMake(scale, 0, 0, scale, tx, ty);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:scale];
    }
}

/**
 长按
 */
-(void)ImageShowDeitalViewDidAlertWithModel:(ImageShowModel *)model{

}

/**
 播放结束
 */
-(void)ImageShowDeitalViewDidPlayEnd:(ImageShowModel *)model playTime:(CGFloat)duration{
    if (self.currentModel == model) {
        self.currentModel.currentPlayTime = (NSInteger)duration;
    }
}

#pragma ImageShowViewHandleDelegate
/**
 查看原图
 */
-(void)ImageShowViewShowOriginalImg{
//    //获取当前显示的cell
    ImageShowDeitalViewCell *cellItem = [self.mainView visibleCells].lastObject;
    [cellItem showOriginalImage];
}

/**
 保存图片/视屏
 */
-(void)ImageShowViewShowDownLoadImg{
    if (self.currentModel.isVideo) {
        [ImageShowToolManager ImageShowDownLoadVideoWithUrl:self.currentModel.viodeUrlStr HUDInView:self savedFinfish:@selector(savedPhotoImage:didFinishSavingWithError:contextInfo:) target:self];
    }else{
        [ImageShowToolManager ImageShowDownLoadImgWithUrl:self.currentModel.imageUrlStr img:self.currentModel.img originalImgUrl:self.currentModel.originUrlStr isOriginal:self.currentModel.isOrigin savedFinfish:@selector(image:didFinishSavingWithError:contextInfo:) target:self];
    }
}

//保存视频完成之后的回调
- (void)savedPhotoImage:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"======保存视频失败%@========", error.localizedDescription);
        [ImageShowHelper showMessage:@"保存到相册失败" container:[UIApplication sharedApplication].keyWindow];
    }
    else {
        NSLog(@"=====保存视频成功=====");
        [ImageShowHelper showMessage:@"保存到相册成功" container:[UIApplication sharedApplication].keyWindow];
    }
}

-(void)ImageShowViewShowEditImg{
    __block   UIImage *icon = self.currentModel.img;
    if (!icon) {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.currentModel.imageUrlStr] options:SDWebImageProgressiveLoad progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (image) {
                icon = image;
                [ImageShowToolManager ImageShowEidtImage:icon savedFinfish:@selector(image:didFinishSavingWithError:contextInfo:) target:self];
            }
        }];
    }else{
        [ImageShowToolManager ImageShowEidtImage:icon savedFinfish:@selector(image:didFinishSavingWithError:contextInfo:) target:self];
    }
}

-(void)ImageShowViewShowShare{
    
}

-(void)ImageShowViewCancel{
    
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    if (image && !error) {
        [ImageShowHelper showMessage:@"保存到相册成功" container:self];
    }else{
        [ImageShowHelper showMessage:@"保存到相册失败" container:self];
    }
}


#pragma UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageShowDeitalViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ImageShowDeitalViewCell class]) forIndexPath:indexPath];
    ImageShowModel *model = self.datas[indexPath.row];
    cell.model = model;
    if (self.bottomView) {
        cell.originalBtnTransFromY = self.bottomView.frame.size.height;
    }
    if (indexPath.row == self.currentIndex) {
        [cell play];
    }
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
//    ImageShowDeitalViewCell *tempCell = (ImageShowDeitalViewCell *)cell;
//    [tempCell pause];
//}

#pragma mark - UIScrollDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    ImageShowDeitalViewCell *tempCell = [self.mainView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    [tempCell pause];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 停止类型1、停止类型2
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        // 停止类型3
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [self scrollViewDidEndScroll];
        }
    }
}

#pragma mark - scrollView 停止滚动监测
- (void)scrollViewDidEndScroll {
    
    NSInteger current = 0;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        current = self.mainView.contentOffset.x / self.mainView.frame.size.width;
    }else{
        current = self.mainView.contentOffset.y / self.mainView.frame.size.height;
    }

    self.currentIndex = current;
    
    if (current <= self.datas.count - 1) {
        self.currentModel = self.datas[current];
    }
    self.topView.currentIndex = current;
    
    !self.currentInfoBlock?:self.currentInfoBlock(self.currentIndex,self.currentModel);
    
    self.topView.isVideo = self.currentModel.isVideo;
    self.iconTitleLabel.text = self.currentModel.iconDes;
    self.iconTitleLabel.hidden = !self.currentModel.iconDes.length;
    
    [self refreshDownLoad];
    
}

-(void)refreshDownLoad{
    self.downLoadBtn.hidden = YES;
    if (self.alertType & ShowImageMangerTypeDownLoadImg && !self.currentModel.isVideo) {
        self.downLoadBtn.hidden = NO;
    }
    if (self.alertType & ShowImageMangerTypeDownVideo && self.currentModel.isVideo) {
        self.downLoadBtn.hidden = NO;
    }
    
    //    //获取当前显示的cell
    //    ImageShowDeitalViewCell *cellItem = [self.mainView visibleCells].lastObject;
    ImageShowDeitalViewCell *cellItem = (ImageShowDeitalViewCell *)[self.mainView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    if (self.showHandle) {
        [UIView animateWithDuration:0.5 animations:^{
            cellItem.originalBtnTransFromY = 0;
        }];
        
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            cellItem.originalBtnTransFromY = self.bottomView.frame.size.height;
        }];
    }
    
    //滚动结束后直接播放
    [cellItem play];
    
    if (self.alertType & ShowImageMangerTypeNone) {
        self.originalBtn.hidden = YES;
    }else{
        if (self.currentModel.isOrigin) {//如果有原图
            NSString *urlStr =  self.currentModel.originUrlStr;
            UIImage *image = [[UIImage alloc]initWithContentsOfFile:image_path(urlStr)];
            if (image) {//如果下载过原图
                self.originalBtn.hidden = YES;
                [self.originalBtn setTitle:@"已完成" forState:UIControlStateNormal];
                [UIView animateWithDuration:0.25 animations:^{
                    self.originalBtn.hidden = YES;
                }];
            }else{//如果没下载过原图
                self.originalBtn.hidden = NO;
                [self.originalBtn setTitle:@"查看原图" forState:UIControlStateNormal];
            }
        } else {
            self.originalBtn.hidden = YES;
        }
        
        if (self.currentModel.isVideo) {
            self.originalBtn.hidden = YES;
        }
    }
    

}

#pragma ImageShowTopHandleViewDelegate
-(void)ImageShowTopHandleViewDidBack{
    
    !self.dismissBlock?:self.dismissBlock();
    [self removeFromSuperview];
}

-(void)ImageShowTopHandleViewDidShareClick{
    
    if (self.alertType & ShowImageMangerTypeShare) {
        !self.shareClickBlock?:self.shareClickBlock(self.currentModel.img, self.currentModel.isVideo ? self.currentModel.viodeUrlStr : self.currentModel.imageUrlStr);
        !self.shareBlock?:self.shareBlock(self.currentModel);
    }
}

-(void)ImageShowTopHandleViewDidEditClick{
    [self ImageShowViewShowEditImg];
}

-(void)reloadWithDatas:(NSMutableArray<ImageShowModel *> *)datas{
    self.datas = datas;
}

-(void)tapClick:(UITapGestureRecognizer *)tap{

}



-(void)originalImg:(UIButton *)btn{
    
    //    //获取当前显示的cell
    ImageShowDeitalViewCell *cellItem = [self.mainView visibleCells].lastObject;
    
    [ImageShowToolManager ImageShowOriginalImg:self.currentModel.originUrlStr complete:^(UIImage *originalImg) {
//        self.iconView.image = originalImg;
        cellItem.downLoadImg = originalImg;
    } porgress:^(NSString *stateTitle) {
        [self.originalBtn setTitle:stateTitle forState:UIControlStateNormal];
        if ([stateTitle isEqualToString:@"已完成"]) {
            [UIView animateWithDuration:0.5 animations:^{
                self.originalBtn.hidden = YES;
            }];
        }
    }];
}

-(void)setAlertType:(ShowImageMangerType)alertType{
    if (alertType == 0) {
        alertType = ShowImageMangerTypeNone;
    }
    _alertType = alertType;
    self.topView.type = alertType;
}

-(void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    self.topView.currentIndex = currentIndex;
}

-(void)setBottomView:(UIView *)bottomView{
    _bottomView = bottomView;
    
    CGRect frame = bottomView.frame;
    CGFloat height = frame.size.height;
    bottomView.frame = CGRectMake(0, self.frame.size.height - height, frame.size.width, height);
    
    self.downLoadBtn.frame = CGRectMake(self.frame.size.width - 80, self.frame.size.height - 120 - height, 40, 40);
    self.iconTitleLabel.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 25 - 10 - height, self.frame.size.width, 25);
    self.originalBtn.frame = CGRectMake((self.frame.size.width - 80) * 0.5, self.frame.size.height - 25 - 25 - 10 - height, 80, 25);
    
}

-(UICollectionViewFlowLayout *)flowLayout{
    if (!_flowLayout) {
        //1.创建layout布局对象
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //2.设置每个item的大小（cell）
        layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        [layout setScrollDirection:self.scrollDirection];
        _flowLayout = layout;
    }
    return _flowLayout;
}

-(UICollectionView *)mainView{
    if (!_mainView) {
        _mainView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _mainView.pagingEnabled = YES;
        _mainView.delegate = self;
        _mainView.dataSource = self;
        _mainView.backgroundColor = [UIColor clearColor];
        _mainView.showsHorizontalScrollIndicator = NO;
        _mainView.showsVerticalScrollIndicator = NO;
        [_mainView registerClass:[ImageShowDeitalViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ImageShowDeitalViewCell class])];
    }
    return _mainView;
}

-(ImageShowTopHandleView *)topView{
    if (!_topView) {
        CGFloat top = 0;
        if (KIsiPhoneX) {
            top = 10;
        }
        _topView = [[ImageShowTopHandleView alloc]initWithFrame:CGRectMake(0, top, self.frame.size.width, 75) delegate:self needBack:YES];
        _topView.totalCount = self.datas.count;
        _topView.currentIndex = 0;
    }
    return _topView;
}

-(UIButton *)originalBtn{
    if (!_originalBtn) {
        _originalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_originalBtn setTitle:@"查看原图" forState:UIControlStateNormal];
        _originalBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _originalBtn.titleLabel.textColor = [UIColor lightGrayColor];
        _originalBtn.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:0.6];
        _originalBtn.layer.borderWidth = 0.5;
        _originalBtn.layer.borderColor = [UIColor clearColor].CGColor;
        _originalBtn.layer.cornerRadius = 25 * 0.5;
        _originalBtn.layer.masksToBounds = YES;
        _originalBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 80) * 0.5, [UIScreen mainScreen].bounds.size.height - 25 - 25 - 10, 80, 25);
        [_originalBtn addTarget:self action:@selector(originalImg:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _originalBtn;
}

-(UIButton *)downLoadBtn{
    if (!_downLoadBtn) {
        _downLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _downLoadBtn.backgroundColor = [UIColor clearColor];
        [_downLoadBtn setBackgroundImage:imageNamed(@"download") forState:UIControlStateNormal];
        _downLoadBtn.frame = CGRectMake(self.frame.size.width - 80, self.frame.size.height - 120, 40, 40);
        [_downLoadBtn addTarget:self action:@selector(ImageShowViewShowDownLoadImg) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _downLoadBtn;
}

-(UILabel *)iconTitleLabel{
    if (!_iconTitleLabel) {
        _iconTitleLabel = [[UILabel alloc]init];
        _iconTitleLabel.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 25 - 10, self.frame.size.width, 25);
        _iconTitleLabel.font = [UIFont systemFontOfSize:18];
        _iconTitleLabel.textAlignment = NSTextAlignmentCenter;
        _iconTitleLabel.textColor = [UIColor whiteColor];
    }
    return _iconTitleLabel;
}

@end
