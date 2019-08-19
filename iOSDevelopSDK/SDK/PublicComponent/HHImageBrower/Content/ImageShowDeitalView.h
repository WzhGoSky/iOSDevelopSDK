//
//  ImageShowDeitalView.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/22.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageShowConfig.h"
@class ImageShowModel;
@protocol ImageShowDeitalViewDelegate <NSObject>
/**
 返回
 */
-(void)ImageShowDeitalViewDidClickBack;
/**
 长按
 */
-(void)ImageShowDeitalViewDidAlertWithModel:(ImageShowModel *)model;

/**
 隐藏
 */
-(void)ImageShowDeitalViewDidDismiss;

/**
 长度隐藏
 */
-(void)ImageShowDeitalViewLongPictureWillDismissTransformY:(CGFloat)transformy scale:(CGFloat)scale;

/**
 播放结束
 */
-(void)ImageShowDeitalViewDidPlayEnd:(ImageShowModel *)model playTime:(CGFloat)duration;

#pragma 短视频相关
-(void)ShortVideoViewCellDidLike;

-(void)ShortVideoViewCellDidComment;

-(void)ShortVideoViewCellDidShare;

-(void)ShortVideoViewCellDidDownLoad;

-(void)ShortVideoViewDidClickUserHeader;

@end

@interface ImageShowDeitalView : UIView

@property (nonatomic, strong) ImageShowModel *model;

@property (nonatomic, weak) id<ImageShowDeitalViewDelegate> delegate;


@end



@interface ImageShowDeitalViewCell : UICollectionViewCell

@property (nonatomic, strong) ImageShowModel *model;

@property (nonatomic, strong) UIImage *downLoadImg;

/**
 查看原图偏移量
 */
@property (nonatomic, assign) CGFloat originalBtnTransFromY;

@property (nonatomic, weak) id<ImageShowDeitalViewDelegate> delegate;

/**
 查看原图
 */
- (void)showOriginalImage;

-(void)pause;

-(void)hiddenSetView;

-(void)showSetView;

-(void)hiddenLongVerticalView:(BOOL)isShow;

-(void)play;
@end


@interface ShortVideoViewCell: ImageShowDeitalViewCell

@property (nonatomic, assign) ShowShortVideoMangerType shortVideoType;

-(void)ImageShowDeitalViewDidDismiss:(BOOL)isShow;

@end

