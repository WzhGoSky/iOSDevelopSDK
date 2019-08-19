//
//  DoodleBoradViewTopHandleView.m
//  AFNetworking
//
//  Created by Hayder on 2019/2/22.
//

#import "DoodleBoradViewTopHandleView.h"

@interface DoodleBoradViewTopHandleView()
@property (nonatomic, strong) UIButton *cancleBtn;
@property (nonatomic, strong) UIButton *finishBtn;
@end

@implementation DoodleBoradViewTopHandleView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.cancleBtn];
        [self addSubview:self.finishBtn];
    }
    return self;
}

-(void)cancelDidClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(doodleBoradViewTopHandleViewDidCacnel:)]) {
        [self.delegate doodleBoradViewTopHandleViewDidCacnel:btn];
    }
}

-(void)cancelDidFinfish:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(doodleBoradViewTopHandleViewDidFinfish:)]) {
        [self.delegate doodleBoradViewTopHandleViewDidFinfish:btn];
    }
}

#pragma lazy
-(UIButton *)cancleBtn{
    if (!_cancleBtn) {
        _cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancleBtn.frame = CGRectMake(0, 0, 88, 44);
        [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancleBtn addTarget:self action:@selector(cancelDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleBtn;
}

-(UIButton *)finishBtn{
    if (!_finishBtn) {
        _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 88, 0, 88, 44);
        [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_finishBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        _finishBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_finishBtn addTarget:self action:@selector(cancelDidFinfish:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishBtn;
}

@end
