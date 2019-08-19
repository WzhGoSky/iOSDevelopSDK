//
//  TZImagePickerController+Extension.m
//  test
//
//  Created by Hayder on 2018/10/3.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "TZImagePickerController+Extension.h"
#import <TZImagePickerController/TZPhotoPickerController.h>
#import "TZPhotoPickerController+Extension.h"
#import "TZPhotoPreviewController+Extension.h"
#import <objc/runtime.h>
#import "RumtimeSwizzle.h"
#import "TZAlbumPickerController+Extension.h"
#import "TZPickerImageConfig.h"
//
//static char *needEditKey = "ImagePickerrNeedEditKey";
//static char *needGetModelsKey = "ImagePickerrNeedGetModelsKey";
//static char *needOriginalKey = "ImagePickerrNeedOriginalKey";

@implementation TZImagePickerController (Extension)

+ (void)load {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [RumtimeSwizzle _methodSwizzleAClass:[self class] Selector:@selector(configDefaultSetting) Selector:@selector(swizzlingConfigDefaultSetting) isClassMethod:NO];
    });
}

-(void)swizzlingConfigDefaultSetting{
    [self swizzlingConfigDefaultSetting];
}


- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index isEdit:(BOOL)isEdit{
    TZPhotoPreviewController *previewVc = [[TZPhotoPreviewController alloc] init];
//    previewVc.canEdit = isEdit;
//    previewVc.needOriginal = NO;
    [TZPickerImageConfig shareInstance].needOriginal = NO;
    self = [super initWithRootViewController:previewVc];
    if (self) {
        self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
        self.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
        [self swizzlingConfigDefaultSetting];

        previewVc.photos = [NSMutableArray arrayWithArray:selectedPhotos];
        previewVc.currentIndex = index;
        __weak typeof(self) weakSelf = self;
        [previewVc setDoneButtonClickBlockWithPreviewType:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                if (!strongSelf) return;
                if (strongSelf.didFinishPickingPhotosHandle) {
                    strongSelf.didFinishPickingPhotosHandle(photos,assets,isSelectOriginalPhoto);
                }
            }];
        }];
    }
    return self;
}

//-(void)setNeedOriginal:(BOOL)needOriginal{
//    objc_setAssociatedObject(self, needOriginalKey, [NSString stringWithFormat:@"%d",needOriginal], OBJC_ASSOCIATION_ASSIGN);
//}
//
//-(BOOL)needOriginal{
//
//    id temp1 = objc_getAssociatedObject(self, needOriginalKey);
//    BOOL temp = [temp1 boolValue];
//    return temp;
//}
//
//
//-(void)setNeedGetModels:(BOOL)needGetModels{
//    objc_setAssociatedObject(self, needGetModelsKey, [NSString stringWithFormat:@"%d",needGetModels], OBJC_ASSOCIATION_ASSIGN);
//}
//
//-(BOOL)needGetModels{
//    id temp1 = objc_getAssociatedObject(self, needGetModelsKey);
//    BOOL temp = [temp1 boolValue];
//    return temp;
//}
//
//-(void)setCanEdit:(BOOL)canEdit{
//    objc_setAssociatedObject(self, needEditKey, [NSString stringWithFormat:@"%d",canEdit], OBJC_ASSOCIATION_ASSIGN);
//}
//
//-(BOOL)canEdit{
//    id temp1 = objc_getAssociatedObject(self, needEditKey);
//    BOOL temp = [temp1 boolValue];
//    return temp;
//}

-(void)newPushPhotoPickerVc{
    //    _didPushPhotoPickerVc = NO;
    [self setValue:@(NO) forKey:@"_didPushPhotoPickerVc"];
    // 1.6.8 判断是否需要push到照片选择页，如果_pushPhotoPickerVc为NO,则不push
    if (![self getPrivateDidPushPhotoPickerVc] && [self getPrivatePushPhotoPickerVc]) {
        TZPhotoPickerController *photoPickerVc = [[TZPhotoPickerController alloc] init];
        photoPickerVc.isFirstAppear = YES;
        photoPickerVc.columnNumber = [self getPrivateColumnNumber];
        [[TZImageManager manager] getCameraRollAlbum:self.allowPickingVideo allowPickingImage:self.allowPickingImage needFetchAssets:NO completion:^(TZAlbumModel *model) {
            photoPickerVc.model = model;
            
            UIViewController *vc = self.visibleViewController;
            if ([vc isKindOfClass:[TZPhotoPickerController class]]) {
                return ;
            }
            [self pushViewController:photoPickerVc animated:YES];
            [self setValue:@(YES) forKey:@"_didPushPhotoPickerVc"];
        }];
    }
}

//
//- (void)pushPhotoPickerVc {
//
//}
//
-(NSInteger)getPrivateColumnNumber{
    id resutl = [self valueForKey:@"columnNumber"];
    return [resutl integerValue];
    //    id result = [RumtimeSwizzle _getPrivateProperty:[self class] name:@"columnNumber"];
    //    return [result integerValue];
}

-(BOOL)getPrivateDidPushPhotoPickerVc{
    id result1 =  [self valueForKey:@"_didPushPhotoPickerVc"];
    return [result1 boolValue];
}
//
-(BOOL)getPrivatePushPhotoPickerVc{
    id result1 =  [self valueForKey:@"_pushPhotoPickerVc"];
    return [result1 boolValue];
}


@end
