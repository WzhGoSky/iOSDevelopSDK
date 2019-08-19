//
//  EmptyView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2017/4/24.
//  Copyright © 2017年 Hayder. All rights reserved.


#import "HHEmptyView.h"
#import "UIView+HHAdditions.h"
#import "globalDefine.h"
#import "UIButton+HHExtension.h"

@interface HHEmptyView()

@property (nonatomic, strong) UIButton *imageButton;

@end

@implementation HHEmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        UIImage *image = [UIImage imageNamed:@"error_no_data"];
        UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [imageButton setImage:image forState:UIControlStateNormal];
        [imageButton addTarget:self action:@selector(didClickImage:) forControlEvents:UIControlEventTouchUpInside];
        [imageButton setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
        [imageButton setTitle:@"亲,暂时没有数据噢" forState:UIControlStateNormal];
        imageButton.titleLabel.font = [UIFont systemFontOfSize:17.f];
        imageButton.adjustsImageWhenHighlighted = NO;
        [imageButton layoutButtonWithEdgeInsetsStyle:HHButtonEdgeInsetsStyleTop imageTitleSpace:5];
        [self addSubview:imageButton];
        self.imageButton = imageButton;
    }
    return self;
}

- (void)setDescriptionText:(NSString *)descriptionText
{
    _descriptionText = descriptionText;
    
    [self.imageButton setTitle:descriptionText forState:UIControlStateNormal];
    [self.imageButton layoutButtonWithEdgeInsetsStyle:HHButtonEdgeInsetsStyleTop imageTitleSpace:5];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    [self.imageButton setImage:image forState:UIControlStateNormal];
    [self.imageButton layoutButtonWithEdgeInsetsStyle:HHButtonEdgeInsetsStyleTop imageTitleSpace:5];
}

- (void)didClickImage:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(emptyViewDidClickImage:)]) {
        [self.delegate emptyViewDidClickImage:self];
    }
}

@end
