//
//  TZPhotoPreviewController+Extension.m
//  test
//
//  Created by Hayder on 2018/10/3.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "TZPhotoPreviewController+Extension.h"
#import <objc/runtime.h>
#import "DrawingManager.h"
#import <Photos/Photos.h>
#import <TZImagePickerController/TZAssetModel.h>
#import <TZImagePickerController/TZImagePickerController.h>
#import <TZImagePickerController/TZPhotoPreviewCell.h>
#import "RumtimeSwizzle.h"
#import "globalDefine.h"

//static char *NeedOriginalBtnKey = "TZPhotoPreviewNeedOriginalBtnKey";
static char *EditBtnKey = "TZPhotoPreviewEditBtnKey";
static char *AlModelsKey = "TZPhotoPreviewAllModelsKey";
#import "TZPickerImageConfig.h"

@implementation TZPhotoPreviewController (Extension)

//-(void)setNeedOriginal:(BOOL)needOriginal{
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",@"TZPhotoPreviewControllerConfigNeedOriginal"]];
//    NSError *error = nil;
//    BOOL result = [[NSString stringWithFormat:@"%d",needOriginal] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
//
//    objc_setAssociatedObject(self, NeedOriginalBtnKey, [NSString stringWithFormat:@"%d",needOriginal], OBJC_ASSOCIATION_ASSIGN);
//}
//
//-(BOOL)needOriginal{
//    id temp1 = objc_getAssociatedObject(self, "TZPEditKey");
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",@"TZPhotoPreviewControllerConfigNeedOriginal"]];
//    NSError *error = nil;
//    NSString *result = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
//    return [result boolValue];
//    //    id temp1 = objc_getAssociatedObject(self, NeedOriginalBtnKey);
//    //    BOOL temp = [temp1 boolValue];
//    //    return temp;
//}
//
//-(void)setCanEdit:(BOOL)canEdit{
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",@"TZPhotoPreviewControllerConfigOrder"]];
//    NSError *error = nil;
//    BOOL result = [[NSString stringWithFormat:@"%d",canEdit] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
//    objc_setAssociatedObject(self, "TZPEditKey", [NSString stringWithFormat:@"%@",canEdit ? @"1" : @"0"], OBJC_ASSOCIATION_RETAIN);
//}
//
//-(BOOL)canEdit{
//    id temp1 = objc_getAssociatedObject(self, "TZPEditKey");
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",@"TZPhotoPreviewControllerConfigOrder"]];
//    NSError *error = nil;
//    NSString *result = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
//    return [result boolValue];
//}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [RumtimeSwizzle _methodSwizzleAClass:[self class] Selector:@selector(configBottomToolBar) Selector:@selector(swizzlingConfigBottomToolBar) isClassMethod:NO];
        [RumtimeSwizzle _methodSwizzleAClass:[self class] Selector:@selector(refreshNaviBarAndBottomBarState) Selector:@selector(swizzlingRefreshNaviBarAndBottomBarState) isClassMethod:NO];
    });
}


-(void)swizzlingRefreshNaviBarAndBottomBarState{
    [self swizzlingRefreshNaviBarAndBottomBarState];
    
    TZAssetModel *model = self.models[self.currentIndex];
    PHAsset *phast = model.asset;
    if (phast.mediaType == PHAssetMediaTypeVideo) {
        self.editBtn.hidden = YES;
    }else{
        BOOL temp = ![TZPickerImageConfig shareInstance].canEdit;
        self.editBtn.hidden = temp;
    }
    
    UIButton *privateOriginalPhotoButton = [self valueForKey:@"_originalPhotoButton"];
    UILabel *privateOriginalPhotoLabel = [self valueForKey:@"_originalPhotoLabel"];
    privateOriginalPhotoButton.hidden= ![TZPickerImageConfig shareInstance].needOriginal;
    privateOriginalPhotoLabel.hidden = ![TZPickerImageConfig shareInstance].needOriginal;
   
}

-(void)swizzlingConfigBottomToolBar{
    [self swizzlingConfigBottomToolBar];
    [self createEditBtn];
}

-(void)setAllModels:(NSMutableArray *)allModels{
    objc_setAssociatedObject(self, AlModelsKey, allModels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableArray *)allModels{
    return objc_getAssociatedObject(self, AlModelsKey);
}

-(void)setEditBtn:(UIButton *)editBtn{
    objc_setAssociatedObject(self, EditBtnKey, editBtn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIButton *)editBtn{
    id temp = objc_getAssociatedObject(self, EditBtnKey);
    return temp;
}

-(void)editBtnClick:(UIButton *)btn{
    NSIndexPath *index = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    TZPhotoPreviewCell * cell = (TZPhotoPreviewCell *)[[self getPrivateCollectionView] cellForItemAtIndexPath:index];
    UIImage *image = cell.previewView.imageView.image;
    __weak typeof(self)wself = self;
    [DrawingManager showSingleDrawing:image type:(DoodleBoardHandleEidt | DoodleBoardHandleSignature | DoodleBoardHandleTailoring | DoodleBoardHandleCode) cancelBlock:^{
        
    } completeBlock:^(UIImage *editImage) {
        if (editImage) {
            [wself dooleViewDidSaveImage:editImage];
        }
    }];
}

- (void)backButtonClick {
    if (self.navigationController.childViewControllers.count < 2) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        if ([self.navigationController isKindOfClass: [TZImagePickerController class]]) {
            TZImagePickerController *nav = (TZImagePickerController *)self.navigationController;
            if (nav.imagePickerControllerDidCancelHandle) {
                nav.imagePickerControllerDidCancelHandle();
            }
        }
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    if (self.backButtonClickBlock) {
        self.backButtonClickBlock([self valueForKey:@"_isSelectOriginalPhoto"]);
    }
}

- (void)dooleViewDidSaveImage:(UIImage *)image
{
//    NSData *data = UIImagePNGRepresentation(image);
//    if (data.length > 10 * 1024 * 1024) {
//        UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width, image.size.height),YES,image.scale);
//        while (data.length > 10 * 1024 * 1024) {
//            [image drawAtPoint:CGPointZero];
//            data = UIImageJPEGRepresentation(image, 2/3);
//        }
//        UIGraphicsEndImageContext();
//        image = [UIImage imageWithData:data];
//    }
    
    //保存照片
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

/**
 图片保存到本地成功
 */
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    
    __weak typeof(self)weakSelf=self;
    PHFetchOptions *options = [[PHFetchOptions alloc]init];
    
    options.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"ascending:NO]];
    
    PHFetchResult * assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    PHAsset *asset = [assetsFetchResults firstObject];
    TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypePhoto];
    
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    for (TZAssetModel *selecModel in _tzImagePickerVc.selectedModels) {
        TZPhotoPreviewCell * cell = (TZPhotoPreviewCell *)[[self getPrivateCollectionView] cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
        if ([selecModel.asset isEqual:cell.previewView.asset]) {
            
            [_tzImagePickerVc.selectedModels insertObject:model atIndex:[_tzImagePickerVc.selectedModels indexOfObject:selecModel]];
            [_tzImagePickerVc.selectedModels removeObject:selecModel];
            break;
        }
    }
    
    for (TZAssetModel *selecModel in self.allModels) {
        TZPhotoPreviewCell * cell = (TZPhotoPreviewCell *)[[self getPrivateCollectionView] cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
        if ([selecModel.asset isEqual:cell.previewView.asset]) {
            [self.allModels insertObject:model atIndex:[self.allModels indexOfObject:selecModel]];
            [self.allModels removeObject:selecModel];
            break;
        }
    }
    
//    [_tzImagePickerVc.selectedModels addObject:model];
    model.isSelected = YES;
    self.models[self.currentIndex] = model;
    
    if (_tzImagePickerVc.selectedModels) {
        
        NSMutableArray *temp = [NSMutableArray array];
        NSMutableArray *tempIDs = [NSMutableArray array];
        
        for (TZAssetModel *model in _tzImagePickerVc.selectedModels) {
            if (model.asset) {
                [temp addObject:model.asset];
                [tempIDs addObject:model.asset.localIdentifier];
            }
        }
        [_tzImagePickerVc setValue:temp forKey:@"_selectedAssets"];
        [_tzImagePickerVc setValue:tempIDs forKey:@"_selectedAssetIds"];
        
        [self setValue:temp forKey:@"_assetsTemp"];
    }
    
//    if ([self getPrivateAssets]) {
//        NSMutableArray *marr = [NSMutableArray arrayWithArray:[self getPrivateAssets]];
//        PHAsset *selectAsset = marr[self.currentIndex];
//        [marr insertObject:asset atIndex:self.currentIndex];
//        [marr removeObject:selectAsset];
//        //        _assetsTemp = [NSArray arrayWithArray:marr];
//        [self setValue:[NSArray arrayWithArray:marr] forKey:@"_assetsTemp"];
//        _tzImagePickerVc.selectedAssets = [NSArray arrayWithArray:marr];
//    }
    [[self getPrivateCollectionView] reloadData];
}

-(NSMutableArray *)getPrivateAssets{
    return [self valueForKey:@"_assetsTemp"];
}

-(UICollectionView *)getPrivateCollectionView{
    UICollectionView *temp = [self valueForKey:@"_collectionView"];
    return temp;
}

-(void)createEditBtn{
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.hidden = YES;
    editBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 25, 0, 50, 40);
    editBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [[self valueForKey:@"_toolBar"] addSubview:editBtn];
    self.editBtn = editBtn;
}

@end
