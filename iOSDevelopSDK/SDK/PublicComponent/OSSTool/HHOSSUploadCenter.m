//
//  HHOSSUploadCenter.m
//  HHForAppStore
//
//  Created by Hayder on 2018/9/10.
//  Copyright © 2018年 Hayder. All rights reserved.
//
#import "HHOSSUploadCenter.h"
#import "HHOSSUploadTool.h"
#import "HHOSSToolHelper.h"
//#import "globalDefine.h"

@interface HHOSSUploadCenter()
/**如果没有传View使用的view*/
@property (nonatomic, strong) UIView *showProgressView;
//外界传进来的View
@property (nonatomic, strong) UIView *showContainerView;
/**重试次数 2次补传 失败就回调给外界*/
@property (nonatomic, assign) NSInteger retryCount;

@property (nonatomic, strong) NSMutableDictionary *currentUploadURLTaskMap;

//取消下载
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation HHOSSUploadCenter

- (instancetype)init
{
    if (self = [super init]) {
        self.retryCount = 2;
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HHOSSUploadCenter alloc] init];
    });
    return _instance;
}

- (void)uploadResourceInArray:(NSArray<HHOSSUploadModel *> *)models HUDInView:(UIView *)view Completion:(void (^)(BOOL, NSArray<HHOSSUploadModel *> *totalList, NSArray<HHOSSUploadModel *> *))completion
{
    self.currentUploadURLTaskMap = [NSMutableDictionary dictionary];
    [self uploadResourceInArrayWithUploadModels:models HUDInView:view totalUploadModels:models Completion:completion];
}

/**
 上传图片,视频,文件到OSS服务器
 @param models 需要上传的对象数组
 @param completion 完成
 */
- (void)uploadResources:(NSArray <id<HHOSSUploadAble>>*)models HUDInView:(UIView *)view Completion:(void (^)(BOOL isSuccessed,NSArray <id<HHOSSUploadAble>> *totalList,NSArray <id<HHOSSUploadAble>> *failedList)) completion
{
    NSMutableArray *uploadModels = [NSMutableArray array];
    for (id<HHOSSUploadAble> uploadModel in models) {
        HHOSSUploadModel *model = [[HHOSSUploadModel alloc] initWithUploadModel:uploadModel];
        [uploadModels addObject:model];
    }
    NSMutableArray <id<HHOSSUploadAble>> *resultTotalList = [NSMutableArray array];
    NSMutableArray <id<HHOSSUploadAble>> *resultFailedList = [NSMutableArray array];
    [self uploadResourceInArrayWithUploadModels:uploadModels HUDInView:view totalUploadModels:uploadModels Completion:^(BOOL isSuccessed, NSArray<HHOSSUploadModel *> *totalList, NSArray<HHOSSUploadModel *> *failedList) {
        for (HHOSSUploadModel *model in totalList) {
            [resultTotalList addObject:model.uploadModel];
        }
        for (HHOSSUploadModel *model in failedList) {
            [resultFailedList addObject:model.uploadModel];
        }
        if (completion) {
            completion(isSuccessed,resultTotalList,resultFailedList);
        }
    }];
}

#pragma mark ---------------------private Func-----------------------------------------
- (void)uploadResourceInArrayWithUploadModels:(NSArray <HHOSSUploadModel *>*)UploadModels HUDInView:(UIView *)view totalUploadModels:(NSArray <HHOSSUploadModel *>*)totalModels Completion:(void (^)(BOOL isSuccessed,NSArray <HHOSSUploadModel *> *totalList,NSArray <HHOSSUploadModel *> *failedList)) completion
{
    //归类
    NSMutableArray *videoList = [NSMutableArray array];
    NSMutableArray *imageList = [NSMutableArray array];
    NSMutableArray *fileList = [NSMutableArray array];
    //上传失败的数组 要进行补传
    NSMutableArray *uploadFailedList = [NSMutableArray array];
    for (HHOSSUploadModel *uploadModel in UploadModels) {
        if (uploadModel.contentType == 0) {//图片
            [imageList addObject:uploadModel];
        }else if(uploadModel.contentType == 1)
        {
            [videoList addObject:uploadModel];
        }else
        {
            [fileList addObject:uploadModel];
        }
    }

    MBProgressHUD *hud = nil;
    if (!view) {
        self.showProgressView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self.showProgressView];
        
        hud = [HHOSSToolHelper HH_showProgressWithDescroption:@"图片上传中" withView:self.showProgressView];
        hud.dimBackground = YES;
        hud.userInteractionEnabled = YES;
        
        [self.showProgressView addSubview:self.cancelButton];
        [self.showProgressView bringSubviewToFront:self.cancelButton];
    }else
    {
        hud = [HHOSSToolHelper HH_showProgressWithDescroption:@"图片上传中" withView:view];
        hud.userInteractionEnabled = YES;
        hud.dimBackground = YES;
        self.showContainerView = view;
        
        [self.showContainerView addSubview:self.cancelButton];
        [self.showContainerView bringSubviewToFront:self.cancelButton];
    }
    
    [HHOSSUploadTool uploadImagesInArray:imageList totalProgerss:^(NSInteger currentIndex, NSInteger totalNum) {
        hud.progress = currentIndex*1.0/totalNum;
        
        hud.detailsLabelText = [NSString stringWithFormat:@"%@ %ld/%ld",@"上传进度:",currentIndex>totalNum?totalNum:currentIndex,totalNum];
    } Completion:^() {
        
        for (HHOSSUploadModel *uploadModel in imageList) {
            if (!uploadModel.imageResourceURL) {
                [uploadFailedList addObject:uploadModel];
            }
        }
        NSLog(@"======上传图片结束=======");
        [HHOSSUploadTool uploadVideosInArray:videoList everyVideoProgress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            hud.labelText = [NSString stringWithFormat:@"%@%.2f%%",@"上传进度",(totalBytesSent*1.0/totalBytesExpectedToSend)*100];
        } totalProgerss:^(NSInteger currentIndex, NSInteger totalNum) {
            hud.progress = currentIndex*1.0/totalNum;
            
            hud.detailsLabelText = [NSString stringWithFormat:@"%@ %ld/%ld", @"视频总进度",currentIndex>totalNum?totalNum:currentIndex,totalNum];
        } Completion:^{
            for (HHOSSUploadModel *uploadModel in videoList) {
                if (!uploadModel.videoResourceURL) {
                    [uploadFailedList addObject:uploadModel];
                }
            }
            
            NSLog(@"=====上传视频结束=====");
            [HHOSSUploadTool uploadFilesInArray:fileList everyFileProgress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                
                hud.labelText = [NSString stringWithFormat:@"%@%.2f%%",@"资源上传d进度:",(totalBytesSent*1.0/totalBytesExpectedToSend)*100];
            } totalProgerss:^(NSInteger currentIndex, NSInteger totalNum) {
                hud.progress = currentIndex*1.0/totalNum;
                
                hud.detailsLabelText = [NSString stringWithFormat:@"%@ %ld/%ld", @"资源上传d进度:",currentIndex>totalNum?totalNum:currentIndex,totalNum];
            } Completion:^{
                for (HHOSSUploadModel *uploadModel in fileList) {
                    if (!uploadModel.fileResourceURL) {
                        [uploadFailedList addObject:uploadModel];
                    }
                }
                
                if (!view) {
                    [HHOSSToolHelper HH_hideActivityHUDInContainView:self.showProgressView];
                    [self.showProgressView removeFromSuperview];
                }else
                {
                    [HHOSSToolHelper HH_hideActivityHUDInContainView:view];
                }
                
                [self.cancelButton removeFromSuperview];
                
                if (uploadFailedList.count == 0) { //全部上传成功
                    
                    if (completion) {
                        completion(YES,totalModels,uploadFailedList);
                        
                        NSLog(@"**=====所有文件上传结束: 成功:%ld个 失败:%ld个**=====",totalModels.count-uploadFailedList.count,uploadFailedList.count);
                    }
                }else //需要补传
                {
                    if (self.retryCount > 0) {
                        [self uploadResourceInArrayWithUploadModels:uploadFailedList HUDInView:view totalUploadModels:totalModels Completion:completion];
                        self.retryCount -- ;
                    }else
                    {
                        if (completion) {
                            completion(NO,totalModels,uploadFailedList);
                        }
                        NSLog(@"**===所有文件上传结束: 成功:%ld个 失败:%ld个**===",totalModels.count-uploadFailedList.count,uploadFailedList.count);
                    }
                }
            }];
        }];
        
    }];
}

- (void)addUploadRequest:(OSSPutObjectRequest *)request ToTaskPoolWithKey:(NSString *)string
{
    [self.currentUploadURLTaskMap setObject:request forKey:string];
}
- (void)removeUploadRequestWithKey:(NSString *)string
{
    [self.currentUploadURLTaskMap removeObjectForKey:string];
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消上传" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _cancelButton.layer.cornerRadius = 5;
        _cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _cancelButton.layer.borderWidth = 1;
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        CGFloat h = [UIScreen mainScreen].bounds.size.height;
        _cancelButton.frame = CGRectMake((w-80)/2, h-50-30, 80, 50);
        [_cancelButton addTarget:self action:@selector(cancelAllTask) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

/**
 取消所有的任务
 */
- (void)cancelAllTask
{
    //隐藏HUD
    [HHOSSToolHelper HH_hideActivityHUDInContainView:self.showProgressView];
    [HHOSSToolHelper HH_hideActivityHUDInContainView:self.showContainerView];
    [self.showProgressView removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    
    NSArray *requestList = self.currentUploadURLTaskMap.allValues;
    for (OSSPutObjectRequest *request in requestList) {
        [request cancel];
    }
}

@end
