//
//  ImageShowBottomHandleView.m
//  test
//
//  Created by Hayder on 2018/9/27.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "ImageShowBottomHandleView.h"

@interface ImageShowBottomHandleView()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation ImageShowBottomHandleView

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

@end
