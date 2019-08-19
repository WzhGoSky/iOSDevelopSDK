//
//  DoodleBoradViewBottomHandleView.m
//  AFNetworking
//
//  Created by Hayder on 2019/2/22.
//

#import "DoodleBoradViewBottomHandleView.h"
#import "DoodleBoardBottomHandleModel.h"
#define imageNamed(imageName) [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"%@@2x",imageName] ofType:@"png" inDirectory:@"DoodleManager.bundle"]]


@interface DoodleBoradViewBottomHandleView()

@property (nonatomic, strong) NSMutableArray *btnArray;

@end

@implementation DoodleBoradViewBottomHandleView

static NSInteger baseTag = 100000;

-(void)setHandlDatas:(NSMutableArray<DoodleBoardBottomHandleModel *> *)handlDatas{
    _handlDatas = handlDatas;
    
    for (UIView *view in self.btnArray) {[view removeFromSuperview];}
    [self.btnArray removeAllObjects];
    
    NSInteger length = handlDatas.count;
    CGFloat width = self.frame.size.width / (CGFloat)length;
    
    for (NSInteger i = 0; i < length; i ++) {
        DoodleBoardBottomHandleModel *model = handlDatas[i];
        UIButton *btn = [self createBtnWIthModel:model frame:CGRectMake(i * width, 0, width, self.frame.size.height)];
        btn.tag = baseTag + i;
        [self addSubview:btn];
        [self.btnArray addObject:btn];
    }
}

-(void)handlClick:(UIButton *)btn{
    NSInteger tag = btn.tag - baseTag;
    DoodleBoardBottomHandleModel *model = self.handlDatas[tag];
    !model.actionBlock?:model.actionBlock();
}

-(UIButton *)createBtnWIthModel:(DoodleBoardBottomHandleModel *)model frame:(CGRect)frame{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setImage:imageNamed(model.unSelectIconName) forState:UIControlStateNormal];
    [btn setImage:imageNamed(model.selectIconNAme)  forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(handlClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}


@end
