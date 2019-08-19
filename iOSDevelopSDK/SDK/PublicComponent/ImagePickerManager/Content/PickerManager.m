//
//  PickerManger.m
//  TZImagePickerController
//
//  Created by Hayder on 2018/9/7.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "PickerManager.h"
#import "PickerManagerConfig.h"
#import "TZImagePickerController+Extension.h"
#import "SysAuthorizationManager.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "PickerModel.h"
#import "PickerDataManager.h"
#import "NSObject+Extension.h"
#import "UIView+ImagePickerExtension.h"
#import "HHVideoCamera.h"
#import "HHAVKitOption.h"
#import "HHNormalCamera.h"
#import "TZImagePickerHelper.h"
#import "DrawingManager.h"
#import "TZPickerImageConfig.h"
#import "globalDefine.h"
#import "UIView+HHAdditions.h"

static NSString *ErrorDomain = @"PickerMangerErrorDomain";

@interface PickerManager()<PickerManagerDelegate,UINavigationControllerDelegate,HHNormalCameraDelegate,TZImagePickerControllerDelegate,HHVideoCameraDelegate>

/**
 选择图片来源
 */
@property (nonatomic, assign) PickerMangerType type;

@property (nonatomic, weak) id<PickerManagerDelegate>  delegate;

@property (nonatomic, strong) NSMutableArray *alertArray;

@property (nonatomic, strong) void(^completeBlock)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto);

@property (nonatomic, strong) TZImagePickerController *tzImagePickerVc;

@property (strong, nonatomic) CLLocation *location;
/**
 目前已经选中的图片数组
 */
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
/**
 是否选择原图
 */
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
/**
 数据源
 */
@property (nonatomic, strong) NSMutableArray<PickerModel *> *modelArray;

@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) PickerManagerConfig *config;

@property (nonatomic, assign) NSInteger imgIndex;

@property (nonatomic, weak) HHNormalCamera *camera;

@end

@implementation PickerManager

static PickerManager *manager = nil;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PickerManager alloc] init];
    });
    return manager;
}

#pragma PickerManagerDelegate
/**
 选择相册事件
 */
-(void)PickerManagerDidClickTakePhoto{
    __weak typeof(self)wself = self;
    if ([self.delegate respondsToSelector:@selector(PickerManagerDidClickTakePhoto)]) {
        [self.delegate PickerManagerDidClickTakePhoto];
    }else{
        [[SysAuthorizationManager sharenInsatnce] requestAuthorization:KALAssetsLibary completion:^(NSError *error) {
            if (!error) {
                [wself pushTZImagePickerController];
            }
        }];
    }
}
- (void)pushTZImagePickerController {
    [TZImagePickerHelper createCacheFloder];
    if (self.config.maxImgCount <= 0) {
        return;
    }
    [self setTZImagePickerConfig];
    [self.tzImagePickerVc newPushPhotoPickerVc];
    
//    self.tzImagePickerVc.canEdit = self.config.albumEdit;
    
    [[PickerManager getCurrentController] presentViewController:self.tzImagePickerVc animated:YES completion:^{
    }];
}


/**
 选择相机事件
 */
-(void)PickerManagerDidClickTakePicker{
    __weak typeof(self)wself = self;
    if ([self.delegate respondsToSelector:@selector(PickerManagerDidClickTakePicker)]) {
        [self.delegate PickerManagerDidClickTakePicker];
    }else{
        [[SysAuthorizationManager sharenInsatnce] requestAuthorization:KAVMediaVideo completion:^(NSError *error) {
            if (!error) {
                [wself pushImagePickerController];
            }
        }];
    }
}

-(void)PickerManagerDidClickTakeCancel{
    if ([self.delegate respondsToSelector:@selector(PickerManagerDidClickTakeCancel)]) {
        [self.delegate PickerManagerDidClickTakeCancel];
    }
}

#pragma mark    -------------------------------------------      相机       -------------------------------------------
- (void)pushImagePickerController {
    [[NSObject getCurrentController].view endEditing:YES];
    // 提前定位
    __weak typeof(self) weakSelf = self;
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = [locations firstObject];
    } failureBlock:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = nil;
    }];
    
    if (self.modelArray.count >= self.config.maxImgCount) {
        
        [[PickerManager getCurrentController].view showTextHUDWithPromptMessage:@"已超出限制张数！" andOffset_y:0 andMargin:10 andDuration:1.5];
        return;
    }
    
    NSInteger maxCount = 1;
    if (self.config.maxPhotoCount != 1) {
        maxCount = (self.config.maxImgCount - self.modelArray.count) > self.config.maxPhotoCount ? (self.config.maxImgCount - self.modelArray.count) : self.config.maxPhotoCount;
    }
    
    HHAVKitOption *option = [[HHAVKitOption alloc] initOnPhotoModeWithSessionPreset:self.config.preset MaxPhotoCount:maxCount];
    HHNormalCamera *camera = [[HHNormalCamera alloc] initWithFrame:[PickerManager getCurrentController].view.bounds Option:option];
    camera.delegate = self;
    [camera showOnContainer:[PickerManager getCurrentController].view];
    self.camera = camera;
    
}

#pragma mark    -------------------------------------------      短视频        -------------------------------------------

/**
 选择短视频
 */
-(void)PickerManagerDidClickTakeShortVideo{
    if ([self.delegate respondsToSelector:@selector(PickerManagerDidClickTakeShortVideo)]) {
        [self.delegate PickerManagerDidClickTakeShortVideo];
    }else{
        
        __weak typeof(self)wself = self;
        
        [[SysAuthorizationManager sharenInsatnce] requestAuthorization:KAVMediaVideo completion:^(NSError *error) {
            if (!error) {
                if (wself.modelArray.count >= wself.config.maxImgCount) {
                    [[PickerManager getCurrentController].view showTextHUDWithPromptMessage:@"已超出限制张数！" andOffset_y:0 andMargin:10 andDuration:1.5];
                    return;
                }
                [[NSObject getCurrentController].view endEditing:YES];
                HHAVKitOption *option = [[HHAVKitOption alloc] initOnVideoModeWithQualityLevel:wself.config.qualityLevel MaxSecond:wself.config.recordMaxTime];
                HHVideoCamera *videoCamea = [[HHVideoCamera alloc] initWithFrame:[PickerManager getCurrentController].view.bounds Option:option];
                videoCamea.delegate = wself;
                [videoCamea showOnContainer:[PickerManager getCurrentController].view];
            }
        }];
    }
}


/**
 保存地址带视频截图和生成的gif图片
 */
-(void)microVideoPath:(NSString *)savePath thumbImage:(UIImage *)image gifFaceURL:(NSString *)imagePath{
    if (savePath) {
        PickerModel *photoModel = [[PickerModel alloc]init];
        photoModel.image = image;
        photoModel.gifPath = imagePath;
        
        [self.modelArray addObject:photoModel];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(savePath)) {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum(savePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

/**
 视频保存成功
 */
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
    
        self.error = [NSError errorWithDomain:ErrorDomain code:1111 userInfo:@{@"expection":@"视频保存失败"}];
        !self.completeBlock?:self.completeBlock(self.modelArray,self.error,NO);
    }else {
        
        PHFetchOptions *options = [[PHFetchOptions alloc]init];
        
        options.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"ascending:NO]];
        
        PHFetchResult*assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
        PHAsset *phast = [assetsFetchResults firstObject];
        
        PickerModel *photoModel = self.modelArray.lastObject;
        photoModel.asset = phast;
        photoModel.videoPath = videoPath;
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        AVAsset *asset = [AVAsset assetWithURL:url];
        photoModel.videoDuration = CMTimeGetSeconds(asset.duration);
        photoModel.videoAsset = asset;
        
        [self.selectedAssets addObject:phast];
        [self.selectedPhotos addObject:photoModel.image];
        
        !self.completeBlock?:self.completeBlock(self.modelArray,nil,YES);
    }
    
}

#pragma mark    -------------------------------------------        UIImagePickerControllerDelegate       -------------------------------------------
- (void)normalCamera:(HHNormalCamera *)camera didFinishedTakingPhoto:(NSArray *)photos{
    if (photos.count == 1) {
        UIImage *image = photos.lastObject;
        // save photo and get asset / 保存图片，获取到asset
        [[PickerManager getCurrentController].view showActivityHUD];
        [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(PHAsset *asset, NSError *error){
            if (error) {
                NSLog(@"======图片保存失败 %@=====",error);
                
                self.error = [NSError errorWithDomain:ErrorDomain code:1111 userInfo:@{@"expection":@"图片保存失败"}];
                !self.completeBlock?:self.completeBlock(self.modelArray,self.error,NO);
            } else {
                //是否允许编辑
                if (self.config.takePhotoEdit) {
                    
                    [[PickerManager getCurrentController].view hideActivityHUD];
                    //单张编辑模式
//                    DrawingConfig *config = [DrawingConfig defaultDrawingConfig];
                    [DrawingManager showSingleDrawing:image type:(DoodleBoardHandleEidt | DoodleBoardHandleSignature | DoodleBoardHandleTailoring | DoodleBoardHandleCode) cancelBlock:^{
                        
                        [[PickerManager getCurrentController].view hideActivityHUD];
                    } completeBlock:^(UIImage *editImg) {
                        if (!editImg) {
                            [PickerDataManager createImageModelWithPHAsset:asset complete:^(PickerModel *model) {
                                [self.modelArray addObject:model];
                                [self.selectedAssets addObject:model.asset];
                                [self.selectedPhotos addObject:model.image];
                                [self.camera hideSelf];
                                !self.completeBlock?:self.completeBlock(self.modelArray,nil,YES);
                            }];
                        }else{
                            [PickerDataManager getEditPhotoModelWithImage:editImg complete:^(PickerModel *model) {
                                
                                [self.modelArray addObject:model];
                                [self.selectedAssets addObject:model.asset];
                                [self.selectedPhotos addObject:model.image];
                                [self.camera hideSelf];
                                !self.completeBlock?:self.completeBlock(self.modelArray,nil,YES);
                            }];
                        }
                    }];
//                    [DrawingManager showSingleDrawing:image config:config complete:^(UIImage *editImg) {
//
//                        if (!editImg) {
//                            [PickerDataManager createImageModelWithPHAsset:asset complete:^(PickerModel *model) {
//                                [self.modelArray addObject:model];
//                                [self.selectedAssets addObject:model.asset];
//                                [self.selectedPhotos addObject:model.image];
//                                [self.camera hideSelf];
//                                !self.completeBlock?:self.completeBlock(self.modelArray,nil,YES);
//                            }];
//                        }else{
//                            [PickerDataManager getEditPhotoModelWithImage:editImg complete:^(PickerModel *model) {
//
//                                [self.modelArray addObject:model];
//                                [self.selectedAssets addObject:model.asset];
//                                [self.selectedPhotos addObject:model.image];
//                                [self.camera hideSelf];
//                                !self.completeBlock?:self.completeBlock(self.modelArray,nil,YES);
//                            }];
//                        }
//                    } cancelBlock:^{
//                        [[PickerManger getCurrentController].view _hideActivityHUD];
//                    }];

                }else{
                    
                    [PickerDataManager getEditPhotoModelWithImage:image complete:^(PickerModel *model) {
                        
                        [[PickerManager getCurrentController].view hideActivityHUD];
                        [self.selectedAssets addObject:model.asset];
                        [self.selectedPhotos addObject:model.image];
                        [self.modelArray addObject:model];
                        [self.camera hideSelf];
                        !self.completeBlock?:self.completeBlock(self.modelArray,nil,YES);
                    }];
                }
            }
        }];
        
    }else{
        
        //多张编辑模式
//        DrawingConfig *config = [DrawingConfig defaultDrawingConfig];
        
        [DrawingManager showASetOfImgsDrawing:photos type:(DoodleBoardHandleEidt | DoodleBoardHandleSignature | DoodleBoardHandleTailoring | DoodleBoardHandleCode) inView:[UIApplication sharedApplication].keyWindow complete:^(NSArray<UIImage *> *editArray) {
            [[PickerManager getCurrentController].view showActivityHUD];
            //连拍
            [PickerDataManager savePhotoWithImages:editArray result:^(NSMutableArray<PickerModel *> *modelArr, NSMutableArray *assets, NSMutableArray *photos) {
                
                [[PickerManager getCurrentController].view hideActivityHUD];
                [self.selectedAssets addObjectsFromArray:assets];
                [self.selectedPhotos addObjectsFromArray:editArray];
                [self.modelArray addObjectsFromArray:modelArr];
                
                !self.completeBlock?:self.completeBlock(self.modelArray,nil,YES);
                
            }];
        }];
        
//        [DrawingManager showASetOfImgsDrawing:photos config:config complete:^(NSArray<UIImage *> *editArray) {
//
//            [[PickerManger getCurrentController].view _showActivityHUD];
//            //连拍
//            [PickerDataManager savePhotoWithImages:editArray result:^(NSMutableArray<PickerModel *> *modelArr, NSMutableArray *assets, NSMutableArray *photos) {
//
//                [[PickerManger getCurrentController].view _hideActivityHUD];
//                [self.selectedAssets addObjectsFromArray:assets];
//                [self.selectedPhotos addObjectsFromArray:editArray];
//                [self.modelArray addObjectsFromArray:modelArr];
//
//                !self.completeBlock?:self.completeBlock(self.modelArray,nil,YES);
//
//            }];
//        }];
        

    }
}

#pragma  mark  -----------------------                     TZImagePickerControllerDelegate                       -----------------------
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    
    //处理视频gif图片
    [self.tzImagePickerVc hideProgressHUD];
    [[NSObject getCurrentController].view hideActivityHUD];
    self.modelArray = assets;
    !self.completeBlock?:self.completeBlock(self.modelArray,nil,isSelectOriginalPhoto);
//    
//    [PickerDataManager getPhotoModelArrWithAssets:assets imageArr:photos result:^(NSMutableArray<PickerModel *> *modelArr, NSMutableArray *assets, NSMutableArray *photos) {
//
//        [[PickerManger getCurrentController].view _hideActivityHUD];
//
//        self.modelArray = modelArr;
//        !self.completeBlock?:self.completeBlock(self.modelArray,nil,isSelectOriginalPhoto);
//    }];
}


// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[animatedImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
}

// Decide album show or not't
// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(PHFetchResult *)result {
    return YES;
}

// Decide asset show or not't
// 决定asset显示与否
- (BOOL)isAssetCanSelect:(PHAsset *)asset {
    return YES;
}

#pragma  mark  -----------------------                     private action                        -----------------------
-(void)setConfig:(PickerManagerConfig *)config{
    _config = config;
    
    self.alertArray = config.alertActions;
    [TZPickerImageConfig shareInstance].needOriginal = config.needOriginal;
    [TZPickerImageConfig shareInstance].needGetModels = YES;
    [TZPickerImageConfig shareInstance].canEdit = config.albumEdit;
}

/**
 设置属性
 */
-(void)setTZImagePickerConfig{
    
    self.tzImagePickerVc.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
    
    if (self.selectedAssets.count >= 1) {
        // 1.设置目前已经选中的图片数组
        NSMutableArray *assets = [NSMutableArray array];
        for (PickerModel *model in self.selectedAssets) {
            [assets addObject:model.asset];
        }
        self.tzImagePickerVc.selectedAssets = assets; // 目前已经选中的图片数组
    }
    self.tzImagePickerVc.allowTakePicture = self.config.showTakePhoto; // 在内部显示拍照按钮
    self.tzImagePickerVc.allowTakeVideo = self.config.showTakeVideo;   // 在内部显示拍视频按
    self.tzImagePickerVc.videoMaximumDuration = self.config.videoMaximumDuration; // 视频最大拍摄时间
    
    // 3. 设置是否可以选择视频/图片/原图
    self.tzImagePickerVc.allowPickingVideo = self.config.allowPickingVideo;
    self.tzImagePickerVc.allowPickingImage = self.config.allowPickingImage;
    self.tzImagePickerVc.allowPickingOriginalPhoto = self.config.allowPickingOriginalPhoto;
    self.tzImagePickerVc.allowPickingGif = self.config.allowPickingGif;
    self.tzImagePickerVc.allowPickingMultipleVideo = self.config.allowPickingMuitlpleVideo; // 是否可以多选视频
    
    // 4. 照片排列按修改时间升序
    self.tzImagePickerVc.sortAscendingByModificationDate = self.config.sortAscending;
    
    /// 5. 单选模式,maxImagesCount为1时才生效
    self.tzImagePickerVc.showSelectBtn = YES;
    self.tzImagePickerVc.allowCrop = self.config.allowCrop;
    self.tzImagePickerVc.needCircleCrop = self.config.needCircleCrop;
    
    // 设置是否显示图片序号
    BOOL extractedExpr = self.config.showSelectedIndex;
    self.tzImagePickerVc.showSelectedIndex = extractedExpr;
//    self.tzImagePickerVc.canEdit = self.config.albumEdit;
    
//    self.tzImagePickerVc.needOriginal = self.config.needOriginal;
    
}

#pragma  mark  -----------------------                     懒加载                       -----------------------
-(NSMutableArray *)alertArray{
    if (!_alertArray) {
        _alertArray = [NSMutableArray array];
    }
    return _alertArray;
}

-(NSMutableArray *)modelArray{
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

-(NSMutableArray *)selectedPhotos{
    if (!_selectedPhotos) {
        _selectedPhotos = [NSMutableArray array];
    }
    return _selectedPhotos;
}

-(NSMutableArray *)selectedAssets{
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray array];
    }
    return _selectedAssets;
}

-(TZImagePickerController *)tzImagePickerVc{
    if (!_tzImagePickerVc) {
        if (self.config.type == PickerMangerTypePreview && self.selectedAssets.count > 0 && self.selectedPhotos.count > 0) {

            _tzImagePickerVc = [[TZImagePickerController alloc]initWithSelectedAssets:self.selectedAssets selectedPhotos:self.selectedPhotos index:self.imgIndex isEdit:self.config.albumEdit];
            __weak typeof(self)wself = self;
            
            [_tzImagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                [[PickerManager getCurrentController].view showActivityHUD];
                [PickerDataManager getPhotoModelArrWithAssets:[assets mutableCopy] imageArr:[photos mutableCopy] result:^(NSMutableArray<PickerModel *> *modelArr, NSMutableArray *assets, NSMutableArray *photos) {
                    
                    [TZImagePickerHelper handlePickerDatas:modelArr complete:^(NSMutableArray *datas) {
                        [[PickerManager getCurrentController].view hideActivityHUD];
                        [[NSObject getCurrentController].view hideActivityHUD];
                        wself.modelArray = datas;
                        !wself.completeBlock?:wself.completeBlock(wself.modelArray,nil,isSelectOriginalPhoto);

                    }];
                    
                }];
            }];
        }else{
            _tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.config.maxImgCount columnNumber:self.config.columnNumber delegate:self pushPhotoPickerVc:YES];
            
//            _tzImagePickerVc.needGetModels = YES;
        }
        
        [_tzImagePickerVc setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
            imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
        }];
        
        _tzImagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
        _tzImagePickerVc.showPhotoCannotSelectLayer = YES;
        _tzImagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        [_tzImagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
//            [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }];
        
        // 设置竖屏下的裁剪尺寸
        NSInteger left = 30;
        NSInteger widthHeight = [UIScreen mainScreen].bounds.size.width - 2 * left;
        NSInteger top = ([UIScreen mainScreen].bounds.size.height- widthHeight) / 2;
        _tzImagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
        _tzImagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    }
    return _tzImagePickerVc;
}

#pragma  mark  -----------------------                     调用接口                         -----------------------
/**
 直接拍照选择
 */
+(void)onlyShowTakePhotoWithSelectArray:(NSMutableArray<PickerModel *> *)modelArray complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete{
    [self onlyShowWithTpye:PickerMangerTypeTakePhoto selectArray:modelArray imgIndex:0 canEdit:YES complete:complete];
}

/**
 直接短视频
 */
+(void)onlyShowShortVideoWithSelectArray:(NSMutableArray<PickerModel *> *)modelArray complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete{
    [self onlyShowWithTpye:PickerMangerTypeShortVideo selectArray:modelArray imgIndex:0 canEdit:YES complete:complete];
}
/**
 相册
 */
+(void)onlyShowAlbumWithSelectArray:(NSMutableArray<PickerModel *> *)modelArray complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete{
    [self onlyShowWithTpye:PickerMangerTypeAlbum selectArray:modelArray imgIndex:0 canEdit:YES complete:complete];
}
/**
 图片预览
 */
+(void)onlyShowPreviewWithSelectArray:(NSMutableArray<PickerModel *> *)modelArray index:(NSInteger)index canEdit:(BOOL)canEdit complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete{
    [self onlyShowWithTpye:PickerMangerTypePreview selectArray:modelArray imgIndex:index canEdit:canEdit complete:complete];
}

+(void)onlyShowPreviewWithSelectArray:(NSMutableArray *)selectAssets selectPhotos:(NSMutableArray *)selectPhotos index:(NSInteger)index canEdit:(BOOL)canEdit complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete{
    PickerManager *manager = [PickerManager shareInstance];
    manager.config = [PickerManagerConfig defaultPickerConfig];
    manager.config.type = PickerMangerTypePreview;
    manager.config.albumEdit = canEdit;
    manager.imgIndex = index;
    __weak typeof(manager)wManager = manager;
    manager.config.cancelBlock = ^{
        [wManager PickerManagerDidClickTakeCancel];
    };
    manager.config.takeShortVideoBlock = ^{
        [wManager PickerManagerDidClickTakeShortVideo];
    };
    manager.config.takePhotoBlock = ^{
        [wManager PickerManagerDidClickTakePicker];
    };
    manager.config.albumBlock = ^{
        [wManager PickerManagerDidClickTakePhoto];
    };
    manager.completeBlock = complete;
    manager.delegate = nil;
    
    manager.selectedPhotos = selectPhotos;
    manager.selectedAssets = selectAssets;
    
    [manager pushTZImagePickerController];
}

+(void)onlyShowWithConfig:(PickerManagerConfig *)config selectArray:(NSMutableArray<PickerModel *> *)modelArray complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete{
    
    if (config.type == PickerMangerTypeShortVideo || config.type == PickerMangerTypeAlbum || config.type == PickerMangerTypeTakePhoto || config.type == PickerMangerTypePreview) {

        [self onlyShowWithConfig:config selectArray:modelArray imgIndex:0 canEdit:NO complete:complete];
    }
    
}

+(void)onlyShowWithConfig:(PickerManagerConfig *)config selectArray:(NSMutableArray<PickerModel *> *)modelArray imgIndex:(NSInteger)index canEdit:(BOOL)canEdit complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete{
    PickerManager *manager = [PickerManager shareInstance];
    manager.config = config;
    if (manager.config.type == PickerMangerTypePreview) {
        manager.config.albumEdit = canEdit;
    }
    manager.imgIndex = index;
    __weak typeof(manager)wManager = manager;
    manager.config.cancelBlock = ^{
        [wManager PickerManagerDidClickTakeCancel];
    };
    manager.config.takeShortVideoBlock = ^{
        [wManager PickerManagerDidClickTakeShortVideo];
    };
    manager.config.takePhotoBlock = ^{
        [wManager PickerManagerDidClickTakePicker];
    };
    manager.config.albumBlock = ^{
        [wManager PickerManagerDidClickTakePhoto];
    };
    manager.completeBlock = complete;
    manager.modelArray = modelArray;
    manager.delegate = nil;
    
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *imgs = [NSMutableArray array];
    for (PickerModel *model in modelArray) {
        if ([model isKindOfClass:[PickerModel class]] && model.asset != nil) {
            [assets addObject:model.asset];
            [imgs addObject:model.image];
        }
    }
    manager.selectedPhotos = imgs;
    manager.selectedAssets = assets;
    
    manager.tzImagePickerVc = nil;
    
    [manager tzImagePickerVc];
    
    if (manager.config.type & PickerMangerTypeAlbum) {
        [manager pushTZImagePickerController];
    }
    
    if (manager.config.type & PickerMangerTypeTakePhoto) {
        [manager PickerManagerDidClickTakePicker];
    }
    
    if (manager.config.type & PickerMangerTypeShortVideo) {
        [manager PickerManagerDidClickTakeShortVideo];
    }
    
    if (manager.config.type & PickerMangerTypePreview) {
        [manager pushTZImagePickerController];
    }
}

+(void)onlyShowWithTpye:(PickerMangerType)type selectArray:(NSMutableArray<PickerModel *> *)modelArray imgIndex:(NSInteger)index canEdit:(BOOL)canEdit complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete{
    
    PickerManagerConfig *config = [PickerManagerConfig defaultPickerConfig];
    config.type = type;
    [self onlyShowWithConfig:config selectArray:modelArray imgIndex:index canEdit:canEdit complete:complete];
    
}

+(void)showPickerWithConfig:(PickerManagerConfig *)config selectArray:(NSMutableArray<PickerModel *> *)modelArray containView:(UIView *)view complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error,BOOL isSelectOriginalPhoto))complete{
    [self showPickerWithdelegate:nil config:config selectArray:modelArray containView:view complete:complete];
}
+(void)showPickerWithdelegate:(id<PickerManagerDelegate>)delegate config:(PickerManagerConfig *)config selectArray:(NSMutableArray<PickerModel *> *)modelArray containView:(UIView *)view complete:(void(^)(NSMutableArray<PickerModel *>*datas, NSError *error, BOOL isSelectOriginalPhoto))complete{
    PickerManager *manager = [PickerManager shareInstance];
    manager.config = config;
    __weak typeof(manager)wManager = manager;
    manager.config.cancelBlock = ^{
        [wManager PickerManagerDidClickTakeCancel];
    };
    manager.config.takeShortVideoBlock = ^{
        [wManager PickerManagerDidClickTakeShortVideo];
    };
    manager.config.takePhotoBlock = ^{
        [wManager PickerManagerDidClickTakePicker];
    };
    manager.config.albumBlock = ^{
        [wManager PickerManagerDidClickTakePhoto];
    };
    manager.completeBlock = complete;
    manager.modelArray = modelArray;
    manager.delegate = delegate;
    
    NSMutableArray *array = [NSMutableArray array];
    for (PickerModel *model in modelArray) {
        if ([model isKindOfClass:[PickerModel class]] && model.asset != nil) {
            [array addObject:model.asset];
        }
    }
    manager.selectedAssets = array;
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:@"请选择上传图片的方式" preferredStyle:UIAlertControllerStyleAlert];
    for (UIAlertAction *alert in manager.alertArray) {
        [alertVc addAction:alert];
    }
    manager.tzImagePickerVc = nil;
    [manager tzImagePickerVc];
    
    if (view) {
        
        [[view viewController] presentViewController:alertVc animated:YES completion:nil];
    }else
    {
        [[PickerManager getCurrentController] presentViewController:alertVc animated:YES completion:^{
            //        manager.tzImagePickerVc.canEdit = manager.config.albumEdit;
        }];
    }
}


@end
