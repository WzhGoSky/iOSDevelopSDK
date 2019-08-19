//
//  PickerConfigManager.m
//  TZImagePickerController
//
//  Created by Hayder on 2018/9/7.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "PickerManagerConfig.h"

@interface PickerManagerConfig()

@property (nonatomic, weak) id<PickerManagerDelegate> delegate;

@end

@implementation PickerManagerConfig


+(instancetype)defaultPickerConfig{
    PickerManagerConfig *manager = [[PickerManagerConfig alloc]init];
    manager.type = (PickerMangerTypeAlbum | PickerMangerTypeTakePhoto | PickerMangerTypeShortVideo);
    manager.allowPickingVideo = YES;
    manager.allowPickingImage = YES;
    manager.albumEdit = YES;
    manager.takePhotoEdit = YES;
    manager.maxImgCount = 12;
    manager.columnNumber = 4;
    manager.allowPickingOriginalPhoto = YES;
    manager.videoMaximumDuration = 60;
    manager.recordMaxTime = 10;
    
    manager.showTakePhoto = NO;
    manager.showTakeVideo = NO;
    manager.allowPickingGif = NO;
    manager.allowCrop = NO;
    manager.needCircleCrop = NO;
    manager.allowPickingMuitlpleVideo = YES;
    manager.showSelectedIndex = YES;
    
    manager.sortAscending = YES;
    
    manager.maxPhotoCount = 1;
    manager.preset = SessionPresetMedium;
    manager.qualityLevel = QualityLevelMedium;
    
    manager.needOriginal = YES;
    return manager;
}

-(void)setType:(PickerMangerType)type{
    _type = type;
    NSMutableArray *temp = [NSMutableArray array];
    if (type & PickerMangerTypeAlbum) {
        [temp addObject:self.photoAction];
    }
    
    if (type & PickerMangerTypeTakePhoto) {
        [temp addObject:self.pickerAction];
    }
    
    if (type & PickerMangerTypeShortVideo) {
        [temp addObject:self.shortVideoAction];
    }
    [temp addObject:self.cancelAction];
    _alertActions = temp;
}

#pragma lazy
-(UIAlertAction *)cancelAction{
    return  [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        !self.cancelBlock?:self.cancelBlock();
    }];
}
-(UIAlertAction *)shortVideoAction{
    return [UIAlertAction actionWithTitle:@"拍摄小视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        !self.takeShortVideoBlock?:self.takeShortVideoBlock();
    }];
}

-(UIAlertAction *)pickerAction{
    return  [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        !self.takePhotoBlock?:self.takePhotoBlock();
    }];
}

-(UIAlertAction *)photoAction{
    return  [UIAlertAction actionWithTitle:@"去相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        !self.albumBlock?:self.albumBlock();
    }];
}
@end
