//
//  TZImagePickerController+Extension.h
//  test
//
//  Created by Hayder on 2018/10/3.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <TZImagePickerController/TZImagePickerController.h>

@interface TZImagePickerController (Extension)

//@property (nonatomic, assign) BOOL canEdit;

/**
 是否直接获取模型
 YES   代理方法- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos 中 assets 直接获取PickerModel模型对象
 NO    则是原先代理方法
 */
//@property (nonatomic, assign) BOOL needGetModels;
//
///**
// 是否需要显示原图按钮
// */
//@property (nonatomic, assign) BOOL needOriginal;

-(void)newPushPhotoPickerVc;

- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index isEdit:(BOOL)isEdit;


@end
