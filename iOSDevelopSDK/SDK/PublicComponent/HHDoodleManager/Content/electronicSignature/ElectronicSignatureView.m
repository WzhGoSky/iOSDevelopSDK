//
//  ElectronicSignatureView.m
//  BaseKit
//
//  Created by Hayder on 2018/10/24.
//

#import "ElectronicSignatureView.h"
#import "ElectronicSignatureTopView.h"
#import "ElectronicSignatureBottomView.h"
#import "SignatureBoardView.h"
#import "UIImage+SignatureExtension.h"

@interface ElectronicSignatureView()
@property (nonatomic, strong) ElectronicSignatureTopView *topView;
@property (nonatomic, strong) ElectronicSignatureBottomView *bottomView;
@property (nonatomic, strong) SignatureBoardView *mainView;
@property (nonatomic, strong) UIImageView *backImageView;
@end

@implementation ElectronicSignatureView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.backImageView];
        [self addSubview:self.topView];
        [self addSubview:self.mainView];
        [self addSubview:self.bottomView];
    }
    return self;
}

static CGFloat topScale = 0.118;
static CGFloat bottomScale = 0.218;

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.topView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height * topScale);
    self.mainView.frame = CGRectMake(0, self.frame.size.height * topScale, self.frame.size.width, self.frame.size.height * (1 - topScale - bottomScale));
    self.bottomView.frame = CGRectMake(0, self.frame.size.height * (1- bottomScale), self.frame.size.width, self.frame.size.height * bottomScale);
}

-(void)setConfig:(ElectronicSignatureConfig *)config{
    _config = config;
    self.topView.config = config;
    self.bottomView.config = config;
}

-(void)finish{
    CGSize size = self.mainView.frame.size;
    UIGraphicsBeginImageContext(size);
    [self.mainView.image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *finalImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    !self.finifshBlock?:self.finifshBlock([self.mainView isEdit] ? finalImg : nil);
}

-(void)clear{
    [self.mainView clean];
}

#pragma lazy
-(ElectronicSignatureBottomView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[ElectronicSignatureBottomView alloc]initWithFrame:CGRectMake(0, self.frame.size.height * (1- bottomScale), self.frame.size.width, self.frame.size.height * bottomScale)];
    }
    return _bottomView;
}

-(SignatureBoardView *)mainView{
    if (!_mainView) {
        _mainView = [[SignatureBoardView alloc]initWithFrame:CGRectMake(0, self.frame.size.height * topScale, self.frame.size.width, self.frame.size.height * (1 - topScale - bottomScale))img: [UIImage imageWithColor:[UIColor clearColor]]];
        _mainView.backgroundColor = [UIColor clearColor];
        _mainView.layer.masksToBounds = YES;
    }
    return _mainView;
}

-(ElectronicSignatureTopView *)topView{
    if (!_topView) {
        __weak typeof(self)wself = self;
        _topView = [[ElectronicSignatureTopView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height * topScale)];
        _topView.leftClickBlock = ^{
            [wself clear];
        };
        _topView.rightClickBlock = ^{
            [wself finish];
        };
    }
    return _topView;
}

-(UIImageView *)backImageView{
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _backImageView.image = [UIImage imageWithColor:[UIColor whiteColor]];
       
    }
    return _backImageView;
}


@end
