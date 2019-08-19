//
//  DoodleBoardViewBottomColorView.m
//  AFNetworking
//
//  Created by Hayder on 2019/2/22.
//

#import "DoodleBoardViewBottomColorView.h"
#import "globalDefine.h"
#import "DoodleBoardBottomHandleModel.h"
#import "UIColor+YYAdd.h"
#import "UIImage+YYAdd.h"

@interface DoodleBoardViewBottomColorView()

@property (nonatomic, strong) UIScrollView *mainView;

/**
 颜色按钮数组
 */
@property (nonatomic, strong) NSMutableArray *btnArray;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, weak) UIButton *selectBtn;

@property (nonatomic, weak) UIButton *undoBtn;

@end

@implementation DoodleBoardViewBottomColorView
static NSInteger baseIndex = 10000;

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.mainView];
        [self addSubview:self.lineView];
    }
    return self;
}

-(void)setUndoState:(BOOL)undoState{
    _undoState = undoState;
    
    self.undoBtn.selected = undoState;
    
}

-(void)setHandeDatas:(NSMutableArray<DoodleBoardBottomHandleModel *> *)handeDatas{
    _handeDatas = handeDatas;
    
    NSInteger length = handeDatas.count;
    self.lineView.hidden = length == 0;
    
    for (UIButton *btn in self.btnArray) {[btn removeFromSuperview];}
    [self.btnArray removeAllObjects];
    
    CGFloat btnW = ([UIScreen mainScreen].bounds.size.width - 40) / (CGFloat)length;
    
    for (NSInteger i = 0; i < length; i ++) {
        DoodleBoardBottomHandleModel *model = handeDatas[i];
        
        UIButton *btn = [self createColorBtnWithModel:model frame:CGRectMake(btnW * i, 0, btnW, self.frame.size.height) index:i];
        
        if (i == 2) {
            btn.selected = YES;
            btn.layer.borderWidth = 4;
        }
        
        [self.btnArray addObject:btn];
        [self.mainView addSubview:btn];
    }
    self.mainView.contentSize = CGSizeMake(length * btnW, 0);
}

-(UIButton *)createColorBtnWithModel:(DoodleBoardBottomHandleModel *)model frame:(CGRect)frame index:(NSInteger)index{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (model.type == DoodleBoardBottomHandleColor) {
            CGFloat WH = frame.size.height;
            btn.frame = CGRectMake(frame.origin.x + (frame.size.width - WH * 0.5) * 0.5, WH * 0.25, WH * 0.5, WH * 0.5);
            NSString *color = [NSString stringWithFormat:@"#%@",model.colorStr];
            UIImage *colorImg = [UIImage imageWithColor:[UIColor colorWithHexString:color]];
            
            [btn setBackgroundImage:colorImg forState:UIControlStateNormal];
            [btn setBackgroundImage:colorImg forState:UIControlStateSelected];
            
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
            btn.layer.borderWidth = 2;
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = WH * 0.5 * 0.5;
    }else{
        btn.frame = frame;
        [btn setImage:[UIImage imageNamed:model.unSelectIconName] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:model.selectIconNAme] forState:UIControlStateSelected];
        btn.layer.borderColor = [UIColor clearColor].CGColor;
        if (model.type == DoodleBoardBottomHandleCancel) {
            self.undoBtn = btn;
        }
        
    }
    
    btn.tag = baseIndex + index;
    
    [btn addTarget:self action:@selector(didChooseColor:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


/**
 选择颜色
 */
-(void)didChooseColor:(UIButton *)btn{
    self.selectBtn.selected = NO;
    
    NSInteger index = btn.tag - baseIndex;
    
    DoodleBoardBottomHandleModel *model = self.handeDatas[index];
    if (model.type == DoodleBoardBottomHandleColor) {
        self.selectBtn.layer.borderWidth = 2;
        btn.selected = YES;
        btn.layer.borderWidth = 4;
        self.selectBtn = btn;
    }
    
    !model.actionBlock?:model.actionBlock();
    
}

#pragma lazy
-(UIScrollView *)mainView{
    if (!_mainView) {
        _mainView = [[UIScrollView alloc]initWithFrame:CGRectMake(20, 0, self.frame.size.width - 40, self.frame.size.height)];
        _mainView.showsVerticalScrollIndicator = NO;
        _mainView.showsHorizontalScrollIndicator = NO;
        _mainView.bounces = NO;
        _mainView.backgroundColor = [UIColor clearColor];
    }
    return _mainView;
}

-(NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 0.5, self.frame.size.width, 0.5)];
        _lineView.backgroundColor = [UIColor whiteColor];
    }
    return _lineView;
}



@end
