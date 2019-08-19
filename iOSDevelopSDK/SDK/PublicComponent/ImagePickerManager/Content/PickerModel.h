//
//  PickerModel.h
//  ForAppStore
//
//  Created by Hayder on 2018/9/15.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface PickerModel : NSObject
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL hadOriginal;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) AVAsset *videoAsset;

//短视频合成gif图片
@property (nonatomic, strong) UIImage *gifImg;
//gif图片本地缓存地址
@property (nonatomic, strong) NSString *gifPath;
//视频播放时长
@property (nonatomic, assign) CGFloat videoDuration;
//缩率图
@property (nonatomic , strong)UIImage *image;
//缩率图大小
@property (nonatomic , assign)CGFloat dataSize;
//缩率图文件名
@property (strong , nonatomic)NSString *fileName;
//缩率图地址
@property (nonatomic, strong) NSString *filePath;

//高清图
@property (nonatomic , strong)UIImage *originImage;
//高清图大小
@property (nonatomic , assign)CGFloat originImageDataSize;
//高清图文件名
@property (nonatomic , strong)NSString *originFileName;
//高清图地址
@property (strong , nonatomic) NSString *originPath;

@property (nonatomic, strong) NSString *assetPath;


+(instancetype)modelWithImage:(UIImage *)image dataSize:(CGFloat)dataSize fileName:(NSString *)fileName filePath:(NSString *)filePath originImage:(UIImage *)originImage originImageDataSize:(CGFloat)originImageDataSize
               originFileName:(NSString *)originFileName originPath:(NSString *)originPath asset:(PHAsset *)PHAsset isVideo:(BOOL)isVideo;
+(instancetype)modelWithAsset:(PHAsset *)asset originImageData:(NSData *)originalData originalFileName:(NSString *)originalFileName lowImageFileName:(NSString *)lowImageFileName;

+(NSMutableArray *)getAssetsWithDatas:(NSMutableArray<PickerModel *> *)datas;
+(NSMutableArray *)getImagesWithDatas:(NSMutableArray<PickerModel *> *)datas;
@end
