//
//  ImageShowConfig.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/22.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#ifndef ImageShowConfig_h
#define ImageShowConfig_h

#import <UIKit/UIKit.h>
#import "ImageShowModel.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import <SDWebImage/SDWebImageManager.h>

@class ImageShowModel;

/**
 图片浏览响应事件
 */
typedef NS_OPTIONS(NSUInteger, ShowImageMangerType) {
    ShowImageMangerTypeNone                                                 = 1 << 0,
    ShowImageMangerTypeOriginalImage                                  = 1 << 1,//查看原图
    ShowImageMangerTypeDownLoadImg                                  = 1 << 2,//保存图片
    ShowImageMangerTypeEdit                                                   = 1 << 3,//编辑
    ShowImageMangerTypeShare                                                = 1 << 4,//分享
    ShowImageMangerTypeDownVideo                                       = 1 << 5//保存视频
};

@protocol ImageShowViewHandleDelegate <NSObject>

-(void)ImageShowViewShowOriginalImg;

-(void)ImageShowViewShowDownLoadImg;

-(void)ImageShowViewShowEditImg;

-(void)ImageShowViewShowShare;

-(void)ImageShowViewCancel;

@end



/**
 短视频 响应事件
 */
typedef NS_OPTIONS(NSUInteger, ShowShortVideoMangerType) {
    ShowShortVideoMangerTypeNone                                                 = 1 << 0,
    ShowShortVideoMangerTypeLike                                  = 1 << 1,//关注
    ShowShortVideoMangerTypeComment                                  = 1 << 2,//评论
    ShowShortVideoMangerTypeShare                                                = 1 << 3,//分享
    ShowShortVideoMangerTypeDownLoad                                               = 1 << 4,//下载
};

@protocol ShoreVideoHandleDelegate <NSObject>

-(void)ShortVideoLike;

-(void)ShortVideoComment;

-(void)ShortVideoShare;

-(void)ShortVideoDownLoad;

-(void)ShortVideoClickUserHeader;

@end

@protocol ShortVideoViewDelegate <NSObject>

-(void)ShortVideoLike:(ImageShowModel *)model index:(NSInteger)index;

-(void)ShortVideoComment:(ImageShowModel *)model index:(NSInteger)index;

-(void)ShortVideoShare:(ImageShowModel *)model index:(NSInteger)index;

-(void)ShortVideoDownLoad:(ImageShowModel *)model index:(NSInteger)index;

-(void)ShortVideoClickUserHeader:(ImageShowModel *)model index:(NSInteger)index;
@end


@protocol ImageShowViewDelegate <NSObject>

@optional

/**
 缩率图片地址
 */
- (NSString *)ImageShowViewImageUrl;
/**
 高清图图片地址
 */
- (NSString *)ImageShowViewOriginalImageUrl;
/**
 视屏资源
 */
- (NSString *)ImageShowViewVideoUrl;
/**
 照片宽度
 */
- (CGFloat)ImageShowViewImageWidth;

/**
 照片高度
 */
- (CGFloat)ImageShowViewImageHeight;
/**
 图片
 */
- (UIImage *)ImageShowViewImage;
/**
 图片文案
 */
- (NSString *)ImageShowViewImageDes;
/**
 s视屏播放时长
 */
- (NSInteger)ImageShowViewImageVideoTime;

#pragma 短视频
/**
 短视频  --- 用户昵称
 */
-(NSString *)ImageShortVideoNickName;
/**
 短视频 --- 用户头像
 */
-(NSString *)ImageShortVideoUserHeaderIcon;
/**
短视频 --- 主标题
 */
-(NSString *)ImageShortVideoTitle;
/**
 短视频 --- 副标题
 */
-(NSString *)ImageShortVideoSubTitle;

@end

#define folderName @"/gzq_img"
#define image_path(imagePath)  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",folderName,[[[[imagePath componentsSeparatedByString:@"://"]lastObject]componentsSeparatedByString:@"/"]componentsJoinedByString:@"_"]]]

#define imageNamed(imageName) [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"%@@2x",imageName] ofType:@"png" inDirectory:@"KDImageShowManager.bundle"]]

#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#endif /* ImageShowConfig_h */
