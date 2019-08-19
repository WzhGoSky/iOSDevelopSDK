//
//  HHOSSUploadModel.h
//  HHForAppStore
//
//  Created by Hayder on 2018/9/10.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHOSSUploadAble.h"

@interface HHOSSUploadModel : NSObject

/**视频类型:0 图片  1:视频  2:文件*/
@property (nonatomic, assign,readonly) NSInteger contentType;
/**----------------------通过协议创建对象---------------------------*/
@property (nonatomic,strong,readonly) id<HHOSSUploadAble> uploadModel;

- (instancetype)initWithUploadModel:(id<HHOSSUploadAble>)uploadModel;
/**------------------------图片对象--------------------------*/
/**上传的图片*/
@property (nonatomic, strong,readonly) UIImage *uploadImage;
/**图片的类型 默认 png*/
@property (nonatomic, strong,readonly) NSString *imageType;
/**压缩比*/
@property (nonatomic, assign,readonly) CGFloat compressionQuality;
/**上传完毕后照片的路径*/
@property (nonatomic, copy) NSString *imageResourceURL;
/***
 默认:
 1.imageType ~ png
 2.compressionQuality ~ 0.1
 */
/**上传的图片*/
- (instancetype)initWithUploadImage:(UIImage *)image;
/**上传的图片*/
- (instancetype)initWithUploadImage:(UIImage *)image imageType:(NSString *)imageType;
/**上传的图片 压缩质量:0~1 推荐*/
- (instancetype)initWithUploadImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality;
/**上传的图片*/
- (instancetype)initWithUploadImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality imageType:(NSString *)imageType;

/**------------------------视频对象--------------------------*/
/**上传视频的路径*/
@property (nonatomic, strong,readonly) NSString *videoPath;
/**上传视频的类型*/
@property (nonatomic, strong,readonly) NSString *videoType;
/**上传的gif图片路径*/
@property (nonatomic, strong,readonly) NSString *gifFacePath;
/**最后上传完毕的URL路径*/
@property (nonatomic, copy) NSString *videoResourceURL;
/**上传完毕gif的路径*/
@property (nonatomic, copy) NSString *gifResourceURL;
//视频播放时长
@property (nonatomic, assign) CGFloat videoTime;
//视频大小
@property (nonatomic, assign) NSInteger videoSize;
/***
 默认:
 1.videoType 默认取路径中的类型
 */
/**
 创建 上传视频对象  视频默认mp4
 @param filePath 上传视频的地址
 @param faceImage 封面图
 */
- (instancetype)initWithUploadVideo:(NSString *)videoPath faceImage:(UIImage *)faceImage;
/**
 创建 上传视频对象
 @param filePath 上传视频的地址
 @param videoType 视频类型
 @param faceImage 封面图
 */
- (instancetype)initWithUploadVideo:(NSString *)videoPath faceImage:(UIImage *)faceImage videoType:(NSString *)videoType;

/**
 创建gif封面的视频上传对象
 */
- (instancetype)initWithUploadVideo:(NSString *)videoPath gifImage:(NSString *)gifImagePath;

/**
 创建静态封面和gif封面的视频上传对象
 */
- (instancetype)initWithUploadVideo:(NSString *)videoPath gifImage:(NSString *)gifImagePath faceImage:(UIImage *)faceImage;
/**------------------------文件对象--------------------------*/
/**上传文件的路径*/
@property (nonatomic, strong,readonly) NSString *filePath;
/**上传文件的类型*/
@property (nonatomic, strong,readonly) NSString *fileType;

/**上传文件的名称 不传使用时间戳*/
@property (nonatomic, strong,readonly) NSString *fileName;

/**最后上传完毕的URL路径*/
@property (nonatomic, copy) NSString *fileResourceURL;

/**上传文件路径
  1.fileType 默认取路径中的类型
 */
- (instancetype)initWithuploadFile:(NSString *)filePath;

/**上传文件路径
 1.fileType 默认取路径中的类型
 */
- (instancetype)initWithuploadFile:(NSString *)filePath fileName:(NSString *)fileName;
/**
 创建上传文件对象

 @param filePath 文件路径
 @param fileType 文件类型
 */
- (instancetype)initWithUploadFile:(NSString *)filePath fileType:(NSString *)fileType;

@end
