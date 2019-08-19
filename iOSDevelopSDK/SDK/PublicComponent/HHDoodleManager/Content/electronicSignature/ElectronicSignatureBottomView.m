//
//  ElectronicSignatureBottomView.m
//  BaseKit
//
//  Created by Hayder on 2018/10/24.
//

#import "ElectronicSignatureBottomView.h"
#import "ElectronicSignatureConfig.h"
#import "UIImage+SignatureExtension.h"
#import "UIColor+SignatureExtension.h"
#import "globalDefine.h"

@interface ElectronicSignatureBottomView()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ElectronicSignatureBottomView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.iconView];
        [self addSubview:self.lineView];
        [self addSubview:self.titleLabel];
    }
    return self;
}

-(void)setConfig:(ElectronicSignatureConfig *)config{
    _config = config;
    
    if (config.lineTintColor) {
        UIImage *xImg = [UIImage imageNamed:@"electronic_X"];
        
        self.iconView.image = [xImg imageWithTintColor:[UIColor colorWithHexString:config.lineTintColor]];
        self.lineView.backgroundColor = [UIColor colorWithHexString:config.lineTintColor];
        self.titleLabel.textColor = [UIColor colorWithHexString:config.lineTintColor];
    }
}

#pragma lazy
-(UIImageView *)iconView{
    if (!_iconView) {
        _iconView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 0, 25, 25)];
        _iconView.image = [UIImage imageNamed:@"electronic_X"];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _iconView;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(30 + 25 + 5, 24, self.frame.size.width - 30 - 25 - 45 - 5, 1)];
        _lineView.backgroundColor = [UIColor grayColor];
    }
    return _lineView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, self.frame.size.width, self.frame.size.height - 25)];
        _titleLabel.text = @"用手指签名";
        _titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end
