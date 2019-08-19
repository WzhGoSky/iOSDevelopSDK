//
//  PickerModel.m
//  ForAppStore
//
//  Created by Hayder on 2018/9/15.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "PickerModel.h"
#import "UIImage+Extension.h"
#define folderName @"/video"
#import <YYImage/YYImage.h>

@implementation PickerModel

+(instancetype)modelWithImage:(UIImage *)image dataSize:(CGFloat)dataSize fileName:(NSString *)fileName filePath:(NSString *)filePath originImage:(UIImage *)originImage originImageDataSize:(CGFloat)originImageDataSize
               originFileName:(NSString *)originFileName originPath:(NSString *)originPath asset:(PHAsset *)PHAsset isVideo:(BOOL)isVideo{
    PickerModel *model = [[PickerModel alloc]init];
    model.isVideo =  isVideo;
    model.asset = PHAsset;
    //缩率图
      model.image = image;
    //缩率图大小
      model.dataSize = dataSize;
    //缩率图文件名
      model.fileName = fileName;
    //缩率图地址
      model.filePath = filePath;
    //高清图
      model.originImage = originImage;
    //高清图大小
      model.originImageDataSize = originImageDataSize;
    //高清图文件名
      model.originFileName = originFileName;
    //高清图地址
      model.originPath = originPath;
    return model;
}

-(void)setAsset:(PHAsset *)asset{
    _asset = asset;
    if ([asset isKindOfClass:[AVURLAsset class]]) {
        self.isVideo = YES;
        self.hadOriginal = NO;
        
        AVURLAsset *avAsset = (AVURLAsset *)asset;
        self.assetPath = avAsset.URL.path;
        
    }else if([asset isKindOfClass:[PHAsset class]]){
        self.isVideo = (asset.mediaType == PHAssetMediaTypeVideo);
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            self.hadOriginal = NO;
        }
        self.assetPath = asset.localIdentifier;
    }
  
}

-(void)setGifPath:(NSString *)gifPath{
    _gifPath = gifPath;
    if (gifPath && !self.gifImg) {
        self.gifImg =  [YYImage imageWithContentsOfFile:gifPath];
    }
}

+(instancetype)modelWithAsset:(PHAsset *)asset originImageData:(NSData *)originalData originalFileName:(NSString *)originalFileName lowImageFileName:(NSString *)lowImageFileName{
    
    PickerModel *model = [[PickerModel alloc]init];
    model.asset = asset;
    
    model.isVideo = ([asset isKindOfClass:[AVAsset class]] || asset.mediaType == PHAssetMediaTypeVideo);
    if ( [asset isKindOfClass:[AVAsset class]] || asset.mediaType == PHAssetMediaTypeVideo) {
        model.hadOriginal = NO;
    }
    
    UIImage *originalImage = [UIImage imageWithData:originalData];
    
    //图片修正方向
    [originalImage fixOrientation];
    
    if (originalImage.size.height > 3000) {
        originalImage = [originalImage imageByScalingToSize:CGSizeMake(3000 / originalImage.size.height * originalImage.size.width, 3000)];
    }
    if(originalImage.size.width > 3000){
        originalImage = [originalImage imageByScalingToSize:CGSizeMake(3000 , 3000 / originalImage.size.width * originalImage.size.height)];
    }
    NSData *data = UIImageJPEGRepresentation(originalImage , 0.1);
    
    //缩率图大小
    model.dataSize =  data.length * 1.0/1024/1024 > 15.0;
    //缩率图地址
    model.filePath = [UIImage saveImage:[UIImage imageWithData:data] andName:@"netWork"];
    //缩率图
    model.image = [UIImage readImageWithName:model.filePath];
    
    //高清图大小
    model.originImageDataSize = originalData.length * 1.0/1024/1024 > 15.0;
    //高清图文件名
    model.originFileName = [UIImage saveImageData:originalData andName:@"netWork2"];
    //高清图地址
    model.originImage = [UIImage readImageWithName:model.originFileName];
    if (model.originImage) {
        model.hadOriginal = YES;
    }
    
    return model;
}

+(NSMutableArray *)getAssetsWithDatas:(NSMutableArray<PickerModel *> *)datas{
    NSMutableArray *temp = [NSMutableArray array];
    for (PickerModel *model in datas) {
        if (model.asset) {[temp addObject:model.asset];}
    }
    return temp;
}

+(NSMutableArray *)getImagesWithDatas:(NSMutableArray<PickerModel *> *)datas{
    NSMutableArray *temp = [NSMutableArray array];
    for (PickerModel *model in datas) {
        if (model.image) {[temp addObject:model.image];}
    }
    return temp;
}


@end
