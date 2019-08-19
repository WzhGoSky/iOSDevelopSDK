//
//  HHOSSUploadModel.m
//  HHForAppStore
//
//  Created by Hayder on 2018/9/10.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHOSSUploadModel.h"

@implementation HHOSSUploadModel

- (instancetype)initWithUploadModel:(id<HHOSSUploadAble>)uploadModel
{
    if (self = [super init]) {
        _uploadModel = uploadModel;
        if ([uploadModel getUploadImage] && ![uploadModel getVideoFilePath]) { //上传图片
            _contentType = 0;
        }
        if ([uploadModel getVideoFilePath]) {//视频上传路径
            _contentType = 1;
        }
        if ([uploadModel getFilePath]) { //文件
            _contentType = 2;
        }
        
        if (_contentType == 0) { //图片 获取图片创建参数

            //上传的视频
            _uploadImage = [uploadModel getUploadImage];
            
            if ([uploadModel respondsToSelector:@selector(getCompressionQuality)]) {
                _compressionQuality = [uploadModel getCompressionQuality];
            }else
            {
                _compressionQuality = 0.1;
            }
            
            if ([uploadModel respondsToSelector:@selector(getImageType)]) {
                _imageType = [uploadModel getImageType];
            }else
            {
                _imageType = @"png";
            }
        }
        
        if (_contentType == 1) { //视频
            //上传的视频
            _videoPath = [uploadModel getVideoFilePath];
            //视频的类型
            NSString *videoType = @"mp4";
            NSArray *components = [_filePath componentsSeparatedByString:@"."];
            if (components.count > 1) {
                videoType = components[1];
            }
            if ([uploadModel respondsToSelector:@selector(getVideoType)]) {
                _videoType = [uploadModel getVideoType];
            }else{
                _videoType = videoType;
            }
            //上传的封面 参数设置
            _uploadImage = [uploadModel getUploadImage];
            if ([uploadModel respondsToSelector:@selector(getCompressionQuality)]) {
                _compressionQuality = [uploadModel getCompressionQuality];
            }else
            {
                _compressionQuality = 0.1;
            }
            
            if ([uploadModel respondsToSelector:@selector(getImageType)]) {
                _imageType = [uploadModel getImageType];
            }else
            {
                _imageType = @"png";
            }
        }
        
        if (_contentType == 2) {
            _filePath = [uploadModel getFilePath];
            //视频的类型
            NSString *fileType = nil;
            NSArray *components = [_filePath componentsSeparatedByString:@"."];
            if (components.count > 1) {
                fileType = components[1];
            }
            if ([uploadModel respondsToSelector:@selector(getFileType)]) {
                _fileType = [uploadModel getFileType];
            }else
            {
                _fileType = fileType;
            }
        }
    }
    return self;
}

/**上传的图片*/
- (instancetype)initWithUploadImage:(UIImage *)image
{
    if (self = [super init]) {
        _contentType = 0;
        _uploadImage = image;
        _imageType = @"png";
        _compressionQuality = 0.1;
    }
    return self;
}

/**
 上传的图片
 */
- (instancetype)initWithUploadImage:(UIImage *)image imageType:(NSString *)imageType
{
    if (self = [super init]) {
        _contentType = 0;
        _uploadImage = image;
        _imageType = imageType;
        _compressionQuality = 0.1;
    }
    return self;
}

- (instancetype)initWithUploadImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality
{
    if (self = [super init]) {
        _contentType = 0;
        _uploadImage = image;
        _compressionQuality = compressionQuality;
        _imageType = @"png";
    }
    return self;
}

/**上传的图片*/
- (instancetype)initWithUploadImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality imageType:(NSString *)imageType
{
    if (self = [super init]) {
        _contentType = 0;
        _uploadImage = image;
        _compressionQuality = compressionQuality;
        _imageType = imageType;
    }
    return self;
}
/**
 上传视频
 @param filePath 上传视频的地址
 @param faceImage 封面图
 */
- (instancetype)initWithUploadVideo:(NSString *)videoPath faceImage:(UIImage *)faceImage
{
    if (self = [super init]) {
        _contentType = 1;
        _videoPath = videoPath;
        _uploadImage = faceImage;
        _videoType = @"mp4";
        _imageType = @"png";
        _compressionQuality = 0.1;
    }
    return self;
}

/**
 创建 上传视频对象
 @param filePath 上传视频的地址
 @param videoType 视频类型
 @param faceImage 封面图
 */
- (instancetype)initWithUploadVideo:(NSString *)videoPath faceImage:(UIImage *)faceImage videoType:(NSString *)videoType
{
    if (self = [super init]) {
        _contentType = 1;
        _videoPath = videoPath;
        _uploadImage = faceImage;
        _videoType = videoType;
        _imageType = @"png";
        _compressionQuality = 0.1;
    }
    return self;
}

/**
 创建gif封面的视频上传对象
 */
- (instancetype)initWithUploadVideo:(NSString *)videoPath gifImage:(NSString *)gifImagePath
{
    if (self = [super init]) {
        _contentType = 1;
        _videoPath = videoPath;
        _gifFacePath = gifImagePath;
        _videoType = @"mp4";
        _compressionQuality = 0.1;
    }
    return self;
}

/**
 创建静态封面和gif封面的视频上传对象
 */
- (instancetype)initWithUploadVideo:(NSString *)videoPath gifImage:(NSString *)gifImagePath faceImage:(UIImage *)faceImage
{
    if (self = [super init]) {
        _contentType = 1;
        _videoPath = videoPath;
        _gifFacePath = gifImagePath;
        _videoType = @"mp4";
        _compressionQuality = 0.1;
        _uploadImage = faceImage;
        _imageType = @"png";
    }
    return self;
}

/**上传文件路径*/
- (instancetype)initWithuploadFile:(NSString *)filePath
{
    if (self = [super init]) {
        _contentType = 2;
        _filePath = filePath;
        _fileType = nil;
        NSArray *components = [_filePath componentsSeparatedByString:@"."];
        if (components.count > 1) {
            _fileType = components[1];
        }
    }
    return self;
}

/**上传文件路径
 1.fileType 默认取路径中的类型
 */
- (instancetype)initWithuploadFile:(NSString *)filePath fileName:(NSString *)fileName
{
    if (self = [super init]) {
        _contentType = 2;
        _filePath = filePath;
        _fileType = nil;
        _fileName = fileName;
        NSArray *components = [_filePath componentsSeparatedByString:@"."];
        if (components.count > 1) {
            _fileType = components[1];
        }
    }
    return self;
}
/**
 创建上传文件对象
 
 @param filePath 文件路径
 @param fileType 文件类型
 */
- (instancetype)initWithUploadFile:(NSString *)filePath fileType:(NSString *)fileType
{
    if (self = [super init]) {
        _contentType = 2;
        _filePath = filePath;
        _fileType = fileType;
    }
    return self;
}


-(void)setVideoPath:(NSString *)videoPath{
    NSData *data = [NSData dataWithContentsOfFile:videoPath];
    self.videoSize = data.length;
}

@end
