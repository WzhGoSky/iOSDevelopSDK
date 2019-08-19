//
//  HHCameraPhotoCell.m
//  HHCamera
//
//  Created by Hayder on 2018/10/5.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHCameraPhotoCell.h"
#import "HHAVKitConfig.h"
#import "HHCameraHelper.h"

@interface HHCameraPhotoCell()

@property (nonatomic, strong) UIImageView *imageView;
//选择按钮
@property (nonatomic, strong) UIButton *selectedButton;

@end

@implementation HHCameraPhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
     
        self.imageView = [[UIImageView alloc] init];
        self.imageView.frame = self.contentView.bounds;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];
        
        self.selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.selectedButton.frame = self.bounds;
        [self.selectedButton setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
        [self.selectedButton setImage:[HHCameraHelper image:[UIImage imageNamed:@"selected"] WithTintColor:kCameraThemeColor] forState:UIControlStateSelected];
        [self.selectedButton addTarget:self action:@selector(selectedOrUnselected:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.selectedButton];
    }
    return self;
}

- (void)setModel:(HHCameraPhoto *)model
{
    _model = model;
    
    self.imageView.image = model.photo;
    self.selectedButton.selected = model.photoSelected;
}

- (void)selectedOrUnselected:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(cameraPhotoCell:didClickSelectedOrUnselected:)]) {
        [self.delegate cameraPhotoCell:self.model didClickSelectedOrUnselected:sender];
    }
}
@end
