//
//  HHCameraPhotoCell.h
//  HHCamera
//
//  Created by Hayder on 2018/10/5.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHCameraPhoto.h"

@protocol HHCameraPhotoCellDelegate<NSObject>

- (void)cameraPhotoCell:(HHCameraPhoto *)model didClickSelectedOrUnselected:(UIButton *)sender;

@end

@interface HHCameraPhotoCell : UICollectionViewCell

@property (nonatomic, weak) id<HHCameraPhotoCellDelegate> delegate;

@property (nonatomic, strong) HHCameraPhoto *model;

@end
