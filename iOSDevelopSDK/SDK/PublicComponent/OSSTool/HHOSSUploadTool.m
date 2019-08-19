//
//  HHOSSUploadTool.m
//  HHForAppStore
//
//  Created by Hayder on 2018/9/10.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHOSSUploadTool.h"
#import "HHOSSNetWorkTool.h"
#import "HHOSSToolHelper.h"
#import "HHOSSUploadCenter.h"

@implementation HHOSSUploadTool
#pragma mark ---------------------uploadImages-----------------------------------------
/**
 批量上传视频
 @param models 视频数组
 @param everyVideoProgress 每个视频上传的进度
 @param totalProgerss 总进度
 @param completion 完成
 */
+ (void)uploadVideosInArray:(NSArray <HHOSSUploadModel *>*)models everyVideoProgress:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))everyVideoProgress totalProgerss:(void (^)(NSInteger currentIndex, NSInteger totalNum))totalProgerss  Completion:(void (^)(void)) completion
{
    if (models.count == 0) {
        completion();
        return;
    }
    
    BOOL isNeedUpload = NO;
    for (int i=0; i<models.count; i++) {
        HHOSSUploadModel *model = models[i];
        if (model.videoPath && !model.videoResourceURL) {
            isNeedUpload = YES;
            break;
        }
    }
    //获取总张数
    NSInteger totalNum = models.count;
    
    if (isNeedUpload) {
        __block NSInteger currentIndex = 1;
        dispatch_group_t group  = dispatch_group_create();
        for (int i=0; i<models.count; i++) {
            __block HHOSSUploadModel *uploadModel = models[i];
            if (!uploadModel.videoResourceURL) { //录像有值,录像URL没有值
                if (currentIndex == 1) { //第一次上传视频，需要把进度传出
                    if (totalProgerss) {
                        totalProgerss(currentIndex,totalNum);
                    }
                }
                dispatch_group_enter(group);
                [self uploadVideoTypeModel:uploadModel progress:everyVideoProgress Completion:^(BOOL isSuccess, HHOSSUploadModel *resultModel, NSError *error) {
                    if (isSuccess) {
                        uploadModel = resultModel;
                        currentIndex ++;
                        if (totalProgerss) {
                            totalProgerss(currentIndex,totalNum);
                        }
                    }
                    dispatch_group_leave(group);
                }];
            }
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            completion();
        });
    }else
    {
        completion();
    }
}

/**
 批量上传图片
 @param models 上传的图片数组对象
 @param totalProgerss 总进度
 @param completion 完成回调
 */
+ (void)uploadImagesInArray:(NSArray <HHOSSUploadModel *>*)models totalProgerss:(void (^)(NSInteger currentIndex, NSInteger totalNum))totalProgerss Completion:(void (^)(void)) completion
{
    if (models.count == 0) {
        completion();
        return;
    }
    
    BOOL isNeedUpload = NO;
    for (int i=0; i<models.count; i++) {
        HHOSSUploadModel *model = models[i];
        if (model.uploadImage && !model.imageResourceURL) {
            isNeedUpload = YES;
            break;
        }
    }
    //获取总张数
    NSInteger totalNum = models.count;
    
    if (isNeedUpload) {
        __block NSInteger currentIndex = 0;
        dispatch_group_t group  = dispatch_group_create();
        for (int i=0; i<models.count; i++) {
            HHOSSUploadModel *model = models[i];
            if (model.uploadImage && !model.imageResourceURL) { //image有值,并且URL没有值
                if (currentIndex == 1) { //第一次上传视频，需要把进度传出
                    if (totalProgerss) {
                        totalProgerss(currentIndex,totalNum);
                    }
                }
                dispatch_group_enter(group);
                NSString *imageName = [self gengerateImageFileNameWithImageType:model.imageType];
                [self uploadImgae:[HHOSSToolHelper fixOrientationWithImage:model.uploadImage] fileName:imageName compressionQuality:model.compressionQuality progress:nil Completion:^(BOOL isSuccess, NSString *url, NSError *error) {
                    if (isSuccess) {
                        model.imageResourceURL = url;
                        if (model.uploadModel) {
                            model.uploadModel.imageResourceURL = url;
                        }
                        
                        currentIndex ++;
                        if (totalProgerss) {
                            totalProgerss(currentIndex,totalNum);
                        }
                    }
                    dispatch_group_leave(group);
                }];
            }
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            completion();
        });
    }else
    {
        completion();
    }
}
/**
 批量上传文件
 @param models 文件数组
 @param everyVideoProgress 每个文件上传的进度
 @param totalProgerss 总进度
 @param completion 完成
 */
+ (void)uploadFilesInArray:(NSArray <HHOSSUploadModel *>*)models everyFileProgress:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))everyFileProgress totalProgerss:(void (^)(NSInteger currentIndex, NSInteger totalNum))totalProgerss  Completion:(void (^)(void)) completion
{
    if (models.count == 0) {
        completion();
        return;
    }
    
    BOOL isNeedUpload = NO;
    for (int i=0; i<models.count; i++) {
        HHOSSUploadModel *model = models[i];
        if (model.filePath && !model.fileResourceURL) {
            isNeedUpload = YES;
            break;
        }
    }
    //获取总张数
    NSInteger totalNum = models.count;
    
    if (isNeedUpload) {
        __block NSInteger currentIndex = 1;
        dispatch_group_t group  = dispatch_group_create();
        for (int i=0; i<models.count; i++) {
            __block HHOSSUploadModel *uploadModel = models[i];
            if (uploadModel.filePath && !uploadModel.fileResourceURL) { //录像有值,录像URL没有值
                if (currentIndex == 1) { //第一次上传视频，需要把进度传出
                    if (totalProgerss) {
                        totalProgerss(currentIndex,totalNum);
                    }
                }
                dispatch_group_enter(group);
                [self uploadFilePath:uploadModel.filePath fileName:uploadModel.fileName?uploadModel.fileName:[self gengerateFileNameWithFileType:uploadModel.fileType] progress:everyFileProgress Completion:^(BOOL isSuccess, NSString *url, NSError *error) {
                    if (isSuccess) {
                        uploadModel.fileResourceURL = url;
                        if (uploadModel.uploadModel) {
                            uploadModel.uploadModel.fileResourceURL = url;
                        }
                        
                        currentIndex ++;
                        if (totalProgerss) {
                            totalProgerss(currentIndex,totalNum);
                        }
                    }
                    dispatch_group_leave(group);
                }];
            }
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            completion();
        });
    }else
    {
        completion();
    }
}

/**
 上传视频类型的对象
 @param model video
 */
+ (void)uploadVideoTypeModel:(HHOSSUploadModel *)model progress:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progress Completion:(void (^)(BOOL isSuccess,HHOSSUploadModel *uploadModel,NSError *error)) completion
{
    if (model.gifFacePath&&model.videoPath&&model.uploadImage) //有gif地址，有上传的封面图，有视频
    {
        [self uploadFilePath:model.gifFacePath fileName:[self gengerateFileNameWithFileType:@"gif"] progress:nil Completion:^(BOOL isSuccess, NSString *url, NSError *error) {
            if (isSuccess) {
                model.gifResourceURL = url;
                if (model.uploadModel) {
                    model.uploadModel.gifResourceURL = url;
                }
                //上传封面图
                [self uploadImgae:[HHOSSToolHelper fixOrientationWithImage:model.uploadImage] fileName:[self gengerateImageFileNameWithImageType:model.imageType] compressionQuality:0 progress:nil Completion:^(BOOL isSuccess, NSString *url, NSError *error) {
                    if (isSuccess) {
                        model.imageResourceURL = url;
                        if (model.uploadModel) {
                            model.uploadModel.imageResourceURL = url;
                        }
                        //上传视频
                        [self uploadVideo:model.videoPath fileName:[self gengerateVideoFileNameWithVideoType:model.videoType] progress:progress Completion:^(BOOL isSuccess, NSString *url, NSError *error) {
                            if (isSuccess) {
                                model.videoResourceURL = url;
                                if (model.uploadModel) {
                                    model.uploadModel.videoResourceURL = url;
                                }
                                if(completion)
                                {
                                    completion(YES,model,nil);
                                }
                            }else
                            {
                                if(completion)
                                {
                                    completion(NO,model,error);
                                }
                            }
                        }];
                        
                    }else
                    {
                        if(completion)
                        {
                            completion(NO,model,error);
                        }
                        
                    }
                }];
            }else
            {
                if(completion)
                {
                    completion(NO,model,error);
                }
                
            }
        }];
    }else  if (model.videoPath && model.uploadImage) { //图片和封面图都有
        [self uploadImgae:[HHOSSToolHelper fixOrientationWithImage:model.uploadImage] fileName:[self gengerateImageFileNameWithImageType:model.imageType] compressionQuality:0 progress:nil Completion:^(BOOL isSuccess, NSString *url, NSError *error) {
                if (isSuccess) {
                    model.imageResourceURL = url;
                    if (model.uploadModel) {
                        model.uploadModel.imageResourceURL = url;
                    }
                    [self uploadVideo:model.videoPath fileName:[self gengerateVideoFileNameWithVideoType:model.videoType] progress:progress Completion:^(BOOL isSuccess, NSString *url, NSError *error) {
                        if (isSuccess) {
                            model.videoResourceURL = url;
                            if (model.uploadModel) {
                                model.uploadModel.videoResourceURL = url;
                            }
                            if(completion)
                            {
                                completion(YES,model,nil);
                            }
                        }else
                        {
                            if(completion)
                            {
                                completion(NO,model,error);
                            }
                        }
                        NSLog(@"video successed--%d----faceURL--%@\n------videoURL--%@\n error:%@",isSuccess,model.imageResourceURL,model.videoResourceURL,error);
                    }];
                    
                }else
                {
                    if(completion)
                    {
                        completion(NO,model,error);
                    }
                    
                }
        }];
    }else if(model.gifFacePath&&model.videoPath) //gif对象
    {
        [self uploadFilePath:model.gifFacePath fileName:[self gengerateFileNameWithFileType:@"gif"] progress:nil Completion:^(BOOL isSuccess, NSString *url, NSError *error) {
            if (isSuccess) {
                model.gifResourceURL = url;
                if (model.uploadModel) {
                    model.uploadModel.gifResourceURL = url;
                }
                [self uploadVideo:model.videoPath fileName:[self gengerateVideoFileNameWithVideoType:model.videoType] progress:progress Completion:^(BOOL isSuccess, NSString *url, NSError *error) {
                    if (isSuccess) {
                        model.videoResourceURL = url;
                        if (model.uploadModel) {
                            model.uploadModel.videoResourceURL = url;
                        }
                        if(completion)
                        {
                            completion(YES,model,nil);
                        }
                    }else
                    {
                        if(completion)
                        {
                            completion(NO,model,error);
                        }
                    }
                }];
                
            }else
            {
                if(completion)
                {
                    completion(NO,model,error);
                }
                
            }
        }];
    }else if (!model.uploadImage&&model.videoPath) //图片没有，视频有
    {
        [self uploadVideo:model.videoPath fileName:[self gengerateVideoFileNameWithVideoType:model.videoType] progress:progress Completion:^(BOOL isSuccess, NSString *url, NSError *error) {
            if (isSuccess) {
                model.videoResourceURL = url;
                if (model.uploadModel) {
                    model.uploadModel.videoResourceURL = url;
                }
                if(completion)
                {
                    completion(YES,model,nil);
                }
            }else
            {
                if(completion)
                {
                    completion(NO,nil,error);
                }
            }
        }];
    }
}

/**
 上传视频

 @param videoPath 视频的路径
 @param fileName 文件名
 @param progress 上传的进度
 */
+ (void)uploadVideo:(NSString *)videoPath fileName:(NSString *)fileName progress:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progress Completion:(void (^)(BOOL isSuccess,NSString *url,NSError *error)) completion
{
    //获取视频的路径
    NSData *data = [NSData dataWithContentsOfFile:videoPath];
    [self uploadData:data fileName:fileName progress:progress Completion:completion];
}

/**
 上传图片
 @param image 图片
 @param fileName 文件名
 @param compressionQuality 压缩质量
 */
+ (void)uploadImgae:(UIImage *)image fileName:(NSString *)fileName compressionQuality:(CGFloat)compressionQuality progress:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progress Completion:(void (^)(BOOL isSuccess,NSString *url,NSError *error)) completion
{
    NSData *data = UIImageJPEGRepresentation(image, compressionQuality);
    [self uploadData:data fileName:fileName progress:progress Completion:completion];
}

/**
 上传文件
 @param image 文件
 @param fileName 文件名
 */
+ (void)uploadFilePath:(NSString *)filePath fileName:(NSString *)fileName progress:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progress Completion:(void (^)(BOOL isSuccess,NSString *url,NSError *error)) completion
{
    //获取视频的路径
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [self uploadData:data fileName:fileName progress:progress Completion:completion];
}

/**
 上传文件
 */
+ (void)uploadData:(NSData *)uploadData fileName:(NSString *)fileName progress:(void (^)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))progress Completion:(void (^)(BOOL isSuccess,NSString *url,NSError *error)) completion
{
    if (uploadData && uploadData.length > 0) {
      OSSPutObjectRequest *request = [HHOSSNetWorkTool OSSPushDataWithName:fileName uploadingData:uploadData progress:progress success:^(OSSTask *task, NSString *fileUrl) {
            if (completion) {
                completion(YES,fileUrl,nil);
            }
          [[HHOSSUploadCenter sharedInstance] removeUploadRequestWithKey:fileName];
        } error:^(OSSTask *task, NSError *error) {
            if (completion) {
                completion(NO,nil,error);
            }
            [[HHOSSUploadCenter sharedInstance] removeUploadRequestWithKey:fileName];
        }];
        [[HHOSSUploadCenter sharedInstance] addUploadRequest:request ToTaskPoolWithKey:fileName];
    }else
    {
        NSLog(@"=====大兄弟,资源是空的,自己赶紧查下========");
        if (completion) {
            completion(NO,nil,[[NSError alloc] init]);
        }
    }
}

/**
 生成图片的名称
 */
+ (NSString *)gengerateImageFileNameWithImageType:(NSString *)imageType
{
    NSInteger salt = arc4random()%10000;
    NSString *fileImage = [NSString stringWithFormat:@"%@%ld.%@",[HHOSSToolHelper currentDateStringWithFormat:@"yyyyMMddHHmmss"],salt,imageType];
    return fileImage;
}

/**
 生成视频的名称
 */
+ (NSString *)gengerateVideoFileNameWithVideoType:(NSString *)videoType
{
    NSInteger salt = arc4random()%10000;
    NSString *fileImage = [NSString stringWithFormat:@"%@%ld.%@",[HHOSSToolHelper currentDateStringWithFormat:@"yyyyMMddHHmmss"],salt,videoType];
    return fileImage;
}

/**
 生成文件内容的名称
 */
+ (NSString *)gengerateFileNameWithFileType:(NSString *)fileType
{
    NSInteger salt = arc4random()%10000;
    NSString *fileName = @"";
    if (fileType) {
        fileName = [NSString stringWithFormat:@"%@%ld.%@",[HHOSSToolHelper currentDateStringWithFormat:@"yyyyMMddHHmmss"],salt,fileType];
    }else
    {
        fileName = [NSString stringWithFormat:@"%@%ld",[HHOSSToolHelper currentDateStringWithFormat:@"yyyyMMddHHmmss"],salt];
    }
    return fileName;
}


@end
