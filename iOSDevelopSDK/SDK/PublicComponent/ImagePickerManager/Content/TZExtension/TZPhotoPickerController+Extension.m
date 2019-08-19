//
//  TZPhotoPickerController+Extension.m
//  test
//
//  Created by Hayder on 2018/10/3.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "TZPhotoPickerController+Extension.h"
#import <objc/runtime.h>
#import "TZPhotoPreviewController+Extension.h"
#import "TZImagePickerController+Extension.h"
#import <TZImagePickerController/UIView+Layout.h>
#import "RumtimeSwizzle.h"
#import "TZImagePickerHelper.h"
#import "TZPickerImageConfig.h"
#import "NSObject+Extension.h"
#import "UIView+ImagePickerExtension.h"

static char *needEditKey = "PhotoPickerNeedEditKey";
static char *needGetModelsKey = "PhotoPickerrNeedGetModelsKey";
static char *needOriginalKey = "PhotoPickerNeedOriginalKey";

@implementation TZPhotoPickerController (Extension)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [RumtimeSwizzle _methodSwizzleAClass:[self class] Selector:@selector(didGetAllPhotos:assets:infoArr:) Selector:@selector(swizzlingDidGetAllPhotos:assets:infoArr:) isClassMethod:NO];
        [RumtimeSwizzle _methodSwizzleAClass:[self class] Selector:@selector(configBottomToolBar) Selector:@selector(swizzlingconfigBottomToolBar) isClassMethod:NO];
        [RumtimeSwizzle _methodSwizzleAClass:[self class] Selector:@selector(fetchAssetModels) Selector:@selector(swizzingfetchAssetModels) isClassMethod:NO];
    });
}

-(void)swizzingfetchAssetModels{
    [self swizzingfetchAssetModels];
}

- (void)swizzlingconfigBottomToolBar {
    [self swizzlingconfigBottomToolBar];
    
    UIButton *originalPhotoButton = [self valueForKey:@"_originalPhotoButton"];
    UILabel *originalPhotoLabel = [self valueForKey:@"_originalPhotoLabel"];
    UIButton *previewButton = [self valueForKey:@"_previewButton"];
    
    originalPhotoButton.hidden = ![TZPickerImageConfig shareInstance].needOriginal;
    originalPhotoLabel.hidden = ![TZPickerImageConfig shareInstance].needOriginal;
    previewButton.hidden = ![TZPickerImageConfig shareInstance].needOriginal;
}


- (void)doneButtonClick {
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    // 1.6.8 判断是否满足最小必选张数的限制
    if (tzImagePickerVc.minImagesCount && tzImagePickerVc.selectedModels.count < tzImagePickerVc.minImagesCount) {
        NSString *title = [NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Select a minimum of %zd photos"], tzImagePickerVc.minImagesCount];
        [tzImagePickerVc showAlertWithTitle:title];
        return;
    }
    
    [tzImagePickerVc showProgressHUD];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *photos;
    NSMutableArray *infoArr;
    if (tzImagePickerVc.onlyReturnAsset) { // not fetch image
        for (NSInteger i = 0; i < tzImagePickerVc.selectedModels.count; i++) {
            TZAssetModel *model = tzImagePickerVc.selectedModels[i];
            [assets addObject:model.asset];
        }
        [self swizzlingDidGetAllPhotos:photos assets:assets infoArr:infoArr];
    } else { // fetch image
        if ([TZPickerImageConfig shareInstance].needGetModels) {
            [TZImagePickerHelper photoPickerHandleModels:tzImagePickerVc.selectedModels photoWidth:tzImagePickerVc.photoWidth complete:^(NSArray *models) {
//                [tzImagePickerVc hideProgressHUD];
                [self newDidGetAllModels:models];
            }];
            
        }else{
            photos = [NSMutableArray array];
            infoArr = [NSMutableArray array];
            for (NSInteger i = 0; i < tzImagePickerVc.selectedModels.count; i++) { [photos addObject:@1];[assets addObject:@1];[infoArr addObject:@1]; }
            
            __block BOOL havenotShowAlert = YES;
            [TZImageManager manager].shouldFixOrientation = YES;
            __block UIAlertController *alertView;
            for (NSInteger i = 0; i < tzImagePickerVc.selectedModels.count; i++) {
                TZAssetModel *model = tzImagePickerVc.selectedModels[i];
                [[TZImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    if (isDegraded) return;
                    if (photo) {
                        if (![TZImagePickerConfig sharedInstance].notScaleImage) {
                            photo = [[TZImageManager manager] scaleImage:photo toSize:CGSizeMake(tzImagePickerVc.photoWidth, (int)(tzImagePickerVc.photoWidth * photo.size.height / photo.size.width))];
                        }
                        [photos replaceObjectAtIndex:i withObject:photo];
                    }
                    if (info)  [infoArr replaceObjectAtIndex:i withObject:info];
                    [assets replaceObjectAtIndex:i withObject:model.asset];
                    
                    for (id item in photos) { if ([item isKindOfClass:[NSNumber class]]) return; }
                    
                    if (havenotShowAlert) {
                        [tzImagePickerVc hideAlertView:alertView];
                        [self swizzlingDidGetAllPhotos:photos assets:assets infoArr:infoArr];
                    }
                } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    // 如果图片正在从iCloud同步中,提醒用户
                    if (progress < 1 && havenotShowAlert && !alertView) {
                        [tzImagePickerVc hideProgressHUD];
                        alertView = [tzImagePickerVc showAlertWithTitle:[NSBundle tz_localizedStringForKey:@"Synchronizing photos from iCloud"]];
                        havenotShowAlert = NO;
                        return;
                    }
                    if (progress >= 1) {
                        havenotShowAlert = YES;
                    }
                } networkAccessAllowed:YES];
            }
        }
        if (tzImagePickerVc.selectedModels.count <= 0 || tzImagePickerVc.onlyReturnAsset) {
            [self swizzlingDidGetAllPhotos:photos assets:assets infoArr:infoArr];
        }
    }
}

- (void)swizzlingDidGetAllPhotos:(NSArray *)photos assets:(NSArray *)assets infoArr:(NSArray *)infoArr{
    [self swizzlingDidGetAllPhotos:photos assets:assets infoArr:infoArr];
}


- (void)newDidGetAllModels:(NSArray *)models {
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    if (tzImagePickerVc.autoDismiss) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self newCallDelegateMethodWithModels:models];
        }];
    } else {
        [self newCallDelegateMethodWithModels:models];
    }
}

- (void)newCallDelegateMethodWithModels:(NSArray *)models {
    
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    [[NSObject getCurrentController].view showActivityHUD];
    [TZImagePickerHelper handlePickerDatas:models complete:^(NSMutableArray *datas) {
        
        [[NSObject getCurrentController].view hideActivityHUD];
        
        if ([tzImagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:infos:)]) {
            [tzImagePickerVc.pickerDelegate imagePickerController:tzImagePickerVc didFinishPickingPhotos:[NSArray array] sourceAssets:datas isSelectOriginalPhoto:[self valueForKey:@"isSelectOriginalPhoto"] infos:[NSArray array]];
        }
    }];
    

}

@end
