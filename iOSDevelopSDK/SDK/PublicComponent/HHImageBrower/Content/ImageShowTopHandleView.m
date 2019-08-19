//
//  ImageShowTopHandleView.m
//  test
//
//  Created by Hayder on 2018/9/27.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "ImageShowTopHandleView.h"

@interface ImageShowTopHandleView()

@property (nonatomic, weak) id<ImageShowTopHandleViewDelegate> delegate;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *editBtn;

@property (nonatomic, assign) BOOL needShareBtn;
@property (nonatomic, assign) BOOL needEditBtn;

@end

@implementation ImageShowTopHandleView

static CGFloat iconWH = 36;
-(instancetype)initWithFrame:(CGRect)frame delegate:(id<ImageShowTopHandleViewDelegate>)delegate needBack:(BOOL)needBack{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        self.needBackBtn = needBack;
        [self addSubview:self.titleLabel];
        
        [self addSubview:self.backBtn];
        [self addSubview:self.shareBtn];
        [self addSubview:self.editBtn];
        
    }
    return self;
}

-(void)setType:(ShowImageMangerType)type{
    _type = type;
    
    self.shareBtn.hidden = YES;
    self.editBtn.hidden = YES;
    
    if (type & ShowImageMangerTypeShare) {
        self.shareBtn.hidden = NO;
    }
    if (type & ShowImageMangerTypeEdit) {
        self.editBtn.hidden = NO;
    }
    
    [self setNeedsLayout];
}

-(void)setTotalCount:(NSInteger)totalCount{
    _totalCount = totalCount;
    self.titleLabel.text = [NSString stringWithFormat:@"%d / %d",(int)(self.currentIndex + 1),(int)totalCount];
}

-(void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    self.titleLabel.text = [NSString stringWithFormat:@"%d / %d",(int)currentIndex + 1,(int)self.totalCount];
}

-(void)setIsVideo:(BOOL)isVideo{
    _isVideo = isVideo;
    
    if (self.type & ShowImageMangerTypeNone) {return;}
    
    if (isVideo && (self.type & ShowImageMangerTypeEdit)) {
        self.editBtn.hidden = YES;
    }else{
        
        self.shareBtn.hidden = YES;
        self.editBtn.hidden = YES;
        
        if (self.type & ShowImageMangerTypeShare) {
            self.shareBtn.hidden = NO;
        }
        if (self.type & ShowImageMangerTypeEdit) {
            self.editBtn.hidden = NO;
        }
        
        [self setNeedsLayout];
    }
    
}


-(void)setNeedBackBtn:(BOOL)needBackBtn{
    _needBackBtn = needBackBtn;
    self.backBtn.hidden = !needBackBtn;
}

-(void)layoutSubviews{
    [super layoutSubviews];

    self.editBtn.frame = CGRectMake(self.frame.size.width - ( self.shareBtn.hidden ? 0 : (self.shareBtn.frame.size.width + 10)) - self.frame.size.height - 10, 0, self.frame.size.height, self.frame.size.height);
}

-(void)backClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(ImageShowTopHandleViewDidBack)]) {
        [self.delegate ImageShowTopHandleViewDidBack];
    }
}

-(void)shareClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(ImageShowTopHandleViewDidShareClick)]) {
        [self.delegate ImageShowTopHandleViewDidShareClick];
    }
}

-(void)editClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(ImageShowTopHandleViewDidEditClick)]) {
        [self.delegate ImageShowTopHandleViewDidEditClick];
    }
}

#pragma lazy
-(UIButton *)editBtn{
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.hidden = YES;
        _editBtn.frame = CGRectMake(self.frame.size.width - ( self.shareBtn.hidden ? 0 : (self.shareBtn.frame.size.width + 10)) - iconWH - 10, (self.frame.size.height - iconWH) * 0.5, iconWH, iconWH);
        [_editBtn setImage:imageNamed(@"doodle_brush_normal") forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(editClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

-(UIButton *)shareBtn{
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareBtn.hidden = YES;
        _shareBtn.frame = CGRectMake(self.frame.size.width - iconWH - 10, (self.frame.size.height - iconWH) * 0.5, iconWH, iconWH);
        [_shareBtn setImage:imageNamed(@"about_icon_share_n") forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}

-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(0, (self.frame.size.height - iconWH) * 0.5, iconWH, iconWH);
        [_backBtn setImage:imageNamed(@"navigation_icon_back_n") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"1 / 0";
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

@end
