//
//  ImageShowConfigManager.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/23.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "ImageShowConfigManager.h"
#import "ImageShowModel.h"
#import "globalDefine.h"

@interface ImageShowConfigManager()

@property (nonatomic, weak) id<ImageShowViewHandleDelegate> delegate;

@property (nonatomic, weak) id<ShoreVideoHandleDelegate> videoDelegate;

@end

@implementation ImageShowConfigManager

static ImageShowConfigManager *manager = nil;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ImageShowConfigManager alloc] init];
    });
    return manager;
}


/**
 短视频播放  根据多选枚举值  来配置操作栏选项
 */
-(NSMutableArray<ImageShortVideoHandleModel *> *)getShortVideoHandleWithType:(ShowShortVideoMangerType)type delegaate:(id<ShoreVideoHandleDelegate>)delegate{
    self.videoDelegate = delegate;
    NSMutableArray *temp = [NSMutableArray array];
    
    if (type & ShowShortVideoMangerTypeLike) {
        [temp addObject:self.ShortVideoLikeModel];
    }
    if (type & ShowShortVideoMangerTypeComment) {
        [temp addObject:self.ShortVideoCommentModel];
    }
    if (type & ShowShortVideoMangerTypeShare) {
        [temp addObject:self.ShortVideoShareModel];
    }
    
    if (type & ShowShortVideoMangerTypeDownLoad) {
        [temp addObject:self.ShortVideoDownLoadModel];
    }
    
    return temp;
}

/**
 根据多选枚举值  来获取alert选项
 */
-(NSMutableArray<UIAlertAction *> *)getConfigAlertWithType:(ShowImageMangerType)type delegate:(id<ImageShowViewHandleDelegate>)delegate{
    
    self.delegate = delegate;
    NSMutableArray *temp = [NSMutableArray array];

    if (type & ShowImageMangerTypeOriginalImage) {
        [temp addObject:self.originalImgAction];
    }
    if (type & ShowImageMangerTypeDownLoadImg) {
        [temp addObject:self.downLoadImgAction];
    }
    if (type & ShowImageMangerTypeEdit) {
        [temp addObject:self.editImgAction];
    }
    if (type & ShowImageMangerTypeShare) {
        [temp addObject:self.shareAction];
    }
    [temp addObject:self.cancelAction];
    return temp;
}

#pragma lazy
-(ImageShortVideoHandleModel *)ShortVideoLikeModel{
    return [ImageShortVideoHandleModel playHandleActionModelWithIcon:@"shortVideo_unlike" selectIconName:@"shortVideo_like" title:nil action:^(UIButton *btn) {
        if ([self.videoDelegate respondsToSelector:@selector(ShortVideoLike)]) {
            [self.videoDelegate ShortVideoLike];
        }
    }];
}

-(ImageShortVideoHandleModel *)ShortVideoCommentModel{
    return [ImageShortVideoHandleModel playHandleActionModelWithIcon:@"shortVideo_comment" selectIconName:@"" title:nil action:^(UIButton *btn) {
        if ([self.videoDelegate respondsToSelector:@selector(ShortVideoComment)]) {
            [self.videoDelegate ShortVideoComment];
        }
    }];
}

-(ImageShortVideoHandleModel *)ShortVideoShareModel{
    return [ImageShortVideoHandleModel playHandleActionModelWithIcon:@"shortVideo_share" selectIconName:@"" title:nil action:^(UIButton *btn) {
        if ([self.videoDelegate respondsToSelector:@selector(ShortVideoShare)]) {
            [self.videoDelegate ShortVideoShare];
        }
    }];
}

-(ImageShortVideoHandleModel *)ShortVideoDownLoadModel{
    return [ImageShortVideoHandleModel playHandleActionModelWithIcon:@"shortVideo_downLoad" selectIconName:@"" title:nil action:^(UIButton *btn) {
        if ([self.videoDelegate respondsToSelector:@selector(ShortVideoDownLoad)]) {
            [self.videoDelegate ShortVideoDownLoad];
        }
    }];
}

-(UIAlertAction *)cancelAction{
    
    return  [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if ([self.delegate respondsToSelector:@selector(ImageShowViewCancel)]) {
                [self.delegate ImageShowViewCancel];
            }
    }];
}
-(UIAlertAction *)originalImgAction{
    
    return  [UIAlertAction actionWithTitle:@"查看原图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.delegate respondsToSelector:@selector(ImageShowViewShowOriginalImg)]) {
            [self.delegate ImageShowViewShowOriginalImg];
        }
    }];
}
-(UIAlertAction *)downLoadImgAction{
    
    return [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.delegate respondsToSelector:@selector(ImageShowViewShowDownLoadImg)]) {
            [self.delegate ImageShowViewShowDownLoadImg];
        }
    }];
}

-(UIAlertAction *)editImgAction{
    return  [UIAlertAction actionWithTitle:@"编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.delegate respondsToSelector:@selector(ImageShowViewShowEditImg)]) {
            [self.delegate ImageShowViewShowEditImg];
        }
    }];
}

-(UIAlertAction *)shareAction{
    return  [UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.delegate respondsToSelector:@selector(ImageShowViewShowShare)]) {
            [self.delegate ImageShowViewShowShare];
        }
    }];
}

@end
