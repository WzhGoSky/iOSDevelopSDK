//
//  ElectronicSignatureTopView.m
//  BaseKit
//
//  Created by Hayder on 2018/10/24.
//

#import "ElectronicSignatureTopView.h"
#import "ElectronicSignatureConfig.h"
#import "UIColor+SignatureExtension.h"
#import "globalDefine.h"

@interface ElectronicSignatureTopView ()
@property (nonatomic, strong) UIButton *clearBtn;
@property (nonatomic, strong) UIButton *completeBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation ElectronicSignatureTopView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.clearBtn];
        [self addSubview:self.completeBtn];
        [self addSubview:self.titleLabel];
        [self addSubview:self.lineView];
    }
    return self;
}

-(void)setConfig:(ElectronicSignatureConfig *)config{
    _config = config;
    
    if (config.topHandeColor.length) {
        [self.clearBtn setTitleColor:[UIColor colorWithHexString:config.topHandeColor] forState:UIControlStateNormal];
        [self.completeBtn setTitleColor:[UIColor colorWithHexString:config.topHandeColor] forState:UIControlStateNormal];
    }
    if (config.lineTintColor.length) {
        self.lineView.backgroundColor = [UIColor colorWithHexString:config.lineTintColor];
    }
    
    if (config.topHandleFont > 0) {
        self.clearBtn.titleLabel.font = [UIFont systemFontOfSize:config.topHandleFont];
        self.completeBtn.titleLabel.font = [UIFont systemFontOfSize:config.topHandleFont];
    }
    
    if (config.topTitleFont > 0) {
        self.titleLabel.font = [UIFont systemFontOfSize:config.topTitleFont];
    }
    
    [self.clearBtn setTitle:config.topLeftTitle forState:UIControlStateNormal];
    [self.completeBtn setTitle:config.topRightTitle forState:UIControlStateNormal];
    self.titleLabel.text = config.titleStr;
}

-(void)didClickClear:(UIButton  *)btn{
    !self.leftClickBlock?:self.leftClickBlock();
}

-(void)didClickComplete:(UIButton *)btn{
    !self.rightClickBlock?:self.rightClickBlock();
}

#pragma lazy
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(44 + 20, 0, self.frame.size.width - (44 + 20) * 2, self.frame.size.height)];
        _titleLabel.text = @"签名";
        _titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

-(UIButton *)completeBtn{
    if (!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _completeBtn.frame = CGRectMake(self.frame.size.width - 44 - 20, 0, 44, self.frame.size.height);
        [_completeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_completeBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_completeBtn addTarget:self action:@selector(didClickComplete:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}
-(UIButton *)clearBtn{
    if (!_clearBtn) {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _clearBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _clearBtn.frame = CGRectMake(20, 0, 44, self.frame.size.height);
        [_clearBtn setTitle:@"清除" forState:UIControlStateNormal];
        [_clearBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_clearBtn addTarget:self action:@selector(didClickClear:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearBtn;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
        _lineView.backgroundColor = [UIColor grayColor];
    }
    return _lineView;
}


@end
