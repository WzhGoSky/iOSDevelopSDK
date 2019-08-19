//
//  ImageShortVideoHandleView.m
//  AFNetworking
//
//  Created by Hayder on 2018/10/31.
//

#import "ImageShortVideoHandleView.h"
#import "UIButton+HHExtension.h"

@interface ImageShortVideoHandleView()
@property (nonatomic, strong) NSArray<ImageShortVideoHandleModel *> *datas;
@end


@implementation ImageShortVideoHandleView

static NSInteger baseIdnex = 100000;
+(instancetype)handleActionViewWithModels:(NSArray<ImageShortVideoHandleModel *> *)models frame:(CGRect)frame{
    ImageShortVideoHandleView *view = [[ImageShortVideoHandleView alloc]initWithFrame:frame];
    view.datas = models;
    return view;
}

-(void)btnClick:(UIButton *)btn{
    ImageShortVideoHandleModel *model = self.datas[btn.tag - baseIdnex];
    !model.handleBlock?:model.handleBlock(btn);
}

-(void)setDatas:(NSArray<ImageShortVideoHandleModel *> *)datas{
    _datas = datas;
    
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [subView removeFromSuperview];
        }
    }
    
    
    NSInteger length = datas.count;
    
    CGFloat btnWH = self.frame.size.width;
    CGFloat space = (self.frame.size.height - length * btnWH) / (double)length;
    
    for (NSInteger i = 0; i < length; i ++) {
        ImageShortVideoHandleModel *model = datas[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, i * (btnWH + space), btnWH, btnWH);
        
        [button setImage:imageNamed(model.iconName) forState:UIControlStateNormal];
        if (model.selectIconName) {
            [button setImage:imageNamed(model.selectIconName) forState:UIControlStateSelected];
        }
        [button setTitle:model.titleStr forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12.f];
        button.tag = baseIdnex+ i;
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [button layoutButtonWithEdgeInsetsStyle:HHButtonEdgeInsetsStyleTop imageTitleSpace:5];
        [self addSubview:button];
    }
    
}

@end
