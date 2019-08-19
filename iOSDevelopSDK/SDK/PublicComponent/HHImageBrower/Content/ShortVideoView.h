//
//  ShortVideoView.h
//  iOSDevelop
//
//  Created by Hayder on 2018/10/31.
//

#import <UIKit/UIKit.h>
#import "ImageShowConfigManager.h"
#import "ImageShowDeitalView.h"

@interface ShortVideoView : UIView
/**
 短视频操作事件
 ShowShortVideoMangerTypeLike                                  = 1 << 1,//关注
 ShowShortVideoMangerTypeComment                                  = 1 << 2,//评论
 ShowShortVideoMangerTypeShare                                                = 1 << 3,//分享
 ShowShortVideoMangerTypeDownLoad                                               = 1 << 4,//下载
 如果配置配有，则block无
 */
#pragma 短视频播放
+(void)showShortVideoWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas handleType:(ShowShortVideoMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock delegate:(id<ShortVideoViewDelegate>)delegate;

+(void)showShortVideoWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas handleType:(ShowShortVideoMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock delegate:(id<ShortVideoViewDelegate>)delegate;

+(void)showShortVideoWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas toIndexPath:(NSInteger)index currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock delegate:(id<ShortVideoViewDelegate>)delegate;

+(void)showShortVideoWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas toIndexPath:(NSInteger)index currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock delegate:(id<ShortVideoViewDelegate>)delegate;

@end
