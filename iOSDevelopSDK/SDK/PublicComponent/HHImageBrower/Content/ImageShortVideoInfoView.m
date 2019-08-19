//
//  ImageShortVideoInfoView.m
//  AFNetworking
//
//  Created by Hayder on 2018/10/31.
//

#import "ImageShortVideoInfoView.h"
#import "ImageShowModel.h"
#import "NSMutableAttributedString+ImageShortVideoExtension.h"

@interface ImageShortVideoInfoView()

/**
 个人信息
 */
@property (nonatomic, strong) UIView *userView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *userNameLabel;

/**
 主要文案
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 副标题
 */
@property (nonatomic, strong) UIScrollView *subInfoContentView;
@property (nonatomic, strong) UILabel *subInfoLabel;

@end

@implementation ImageShortVideoInfoView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        [self addSubview:self.userView];
        [self.userView addSubview:self.iconView];
        [self.userView addSubview:self.userNameLabel];
        
        [self addSubview:self.titleLabel];
        
        [self addSubview:self.subInfoContentView];
        [self.subInfoContentView addSubview:self.subInfoLabel];
    }
    return self;
}

-(void)setModel:(ImageShowModel *)model{
    _model = model;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.userHeader] placeholderImage:[UIImage imageNamed:@"icon_place"]];
    self.userNameLabel.text = model.nickName;
    
    self.titleLabel.text = model.shortVideoTitle;
    
    self.subInfoLabel.attributedText = [self getShortVideoSubTitleAtt];
    
    self.subInfoContentView.contentSize = CGSizeMake(0, [self getShortVidelSubHeight]);
    
    [self setNeedsLayout];
}

-(NSMutableAttributedString *)getShortVideoSubTitleAtt{
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:self.model.shortVideoSubTItle attributes:[NSMutableAttributedString getAttDictWithLineSpacing:5 font:[UIFont systemFontOfSize:13.0] color:[UIColor whiteColor]]];
    return att;
}

-(CGFloat)getShortVidelSubHeight{
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:self.model.shortVideoSubTItle attributes:[NSMutableAttributedString getAttDictWithLineSpacing:5 font:[UIFont systemFontOfSize:13.0] color:[UIColor whiteColor]]];
    return [att getCommentStrHeightWithWidth:[UIScreen mainScreen].bounds.size.width - 30];
}


-(void)iconClick{
    if ([self.delegate respondsToSelector:@selector(ImageShortVideoInfoViewDidClickUserheader:)]) {
        [self.delegate ImageShortVideoInfoViewDidClickUserheader:self.model];
    }
}

static CGFloat space = 10;

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.userView.frame = CGRectMake(0, 0, self.frame.size.width, 40);
    self.iconView.frame = CGRectMake(0, 0, 40, 40);
    self.userNameLabel.frame = CGRectMake(40 + space , 0, self.frame.size.width - 40 - space, self.userView.frame.size.height);
    self.titleLabel.frame = CGRectMake(space , CGRectGetMaxY(self.userView.frame) + space, self.frame.size.width - 2 * space, 2 * space);
    
    self.subInfoContentView.frame = CGRectMake(space , CGRectGetMaxY(self.titleLabel.frame) + space, self.frame.size.width - (2 * space), self.frame.size.height - CGRectGetMaxY(self.titleLabel.frame) - space);
    self.subInfoLabel.frame = self.subInfoContentView.bounds;
}

#pragma lazy
-(UILabel *)subInfoLabel{
    if (!_subInfoLabel) {
        _subInfoLabel = [[UILabel alloc]initWithFrame:self.subInfoContentView.bounds];
        _subInfoLabel.userInteractionEnabled = YES;
        _subInfoLabel.numberOfLines = 0;
        _subInfoLabel.font = [UIFont systemFontOfSize:13.0];
        _subInfoLabel.textColor = [UIColor whiteColor];
    }
    return _subInfoLabel;
}

-(UIScrollView *)subInfoContentView{
    if (!_subInfoContentView) {
        _subInfoContentView = [[UIScrollView alloc]initWithFrame:CGRectMake(10 , CGRectGetMaxY(self.titleLabel.frame) + 15, self.frame.size.width - 20, self.frame.size.height - CGRectGetMaxY(self.titleLabel.frame) - 15)];
        _subInfoContentView.showsVerticalScrollIndicator = NO;
        _subInfoContentView.showsHorizontalScrollIndicator = NO;
        _subInfoContentView.backgroundColor = [UIColor clearColor];
        _subInfoContentView.layer.masksToBounds = YES;
    }
    return _subInfoContentView;
}


-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10 , CGRectGetMaxY(self.userView.frame) + 10, self.frame.size.width - 20, 20)];
        _titleLabel.userInteractionEnabled = YES;
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

-(UILabel *)userNameLabel{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(40 + 10 , 0, self.frame.size.width - 40 - 10, self.userView.frame.size.height)];
        _userNameLabel.userInteractionEnabled = YES;
        _userNameLabel.font = [UIFont systemFontOfSize:15.0];
        _userNameLabel.textColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iconClick)];
        [_userNameLabel addGestureRecognizer:tap];
    }
    return _userNameLabel;
}


-(UIView *)userView{
    if (!_userView) {
        _userView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    }
    return _userView;
}

-(UIImageView *)iconView{
    if (!_iconView) {
        _iconView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.userInteractionEnabled = YES;
        _iconView.layer.cornerRadius = 20;
        _iconView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iconClick)];
        [_iconView addGestureRecognizer:tap];
    }
    return _iconView;
}

@end
