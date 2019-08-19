//
//  ImageShowModel.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/22.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageShowConfig.h"

@interface ImageShowModel : NSObject

@property (nonatomic, assign) BOOL isVideo;

@property (nonatomic, strong) NSString *viodeUrlStr;
/**
 大图地址
 */
@property (nonatomic , strong)NSString *imageUrlStr;

/**
 是否有原图
 */
@property (nonatomic , assign)BOOL isOrigin;

/**
 原图地址
 */
@property (nonatomic , strong)NSString *originUrlStr;

/**
 照片宽度
 */
@property (assign , nonatomic) CGFloat imgWidth;

/**
 照片高度
 */
@property (assign , nonatomic) CGFloat imgHeight;

/**
 图片
 */
@property (nonatomic, strong) UIImage *img;

/**
 文案
 */
@property (nonatomic, strong) NSString *iconDes;


#pragma 短视频信息相关
/**
 昵称
 */
@property (nonatomic, strong) NSString *nickName;
/**
 头像
 */
@property (nonatomic, strong) NSString *userHeader;
/**
 主标题
 */
@property (nonatomic, strong) NSString *shortVideoTitle;
/**
 副标题
 */
@property (nonatomic, strong) NSString *shortVideoSubTItle;

/**
 原图是否是gif图片
 */
@property (nonatomic, assign, readonly) BOOL isOriginGif;
/**
 缩率图是否是gif图片
 */
@property (nonatomic, assign, readonly) BOOL isGif;
/**
 gift图片
 */
@property (nonatomic, strong) UIImage *gifImg;

/**
 视屏时长
 */
@property (nonatomic, assign) NSInteger videoTime;


/**
 记录视屏当前播放时间
 */
@property (nonatomic, assign) NSTimeInterval currentPlayTime;
@end



#pragma 短视频操作模型
@interface ImageShortVideoHandleModel: NSObject
@property (nonatomic, strong) NSString *iconName;
@property (nonatomic, strong) NSString *selectIconName;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) void(^handleBlock)(UIButton *btn);
+(instancetype)playHandleActionModelWithIcon:(NSString *)icon selectIconName:(NSString *)selectIconName title:(NSString *)title action:(void(^)(UIButton *btn))action;
@end
