//
//  DoodleBoardConfig.m
//  AFNetworking
//
//  Created by Hayder on 2019/3/6.
//

#import "DoodleBoardConfig.h"


@interface DoodleBoardConfig()

@property (nonatomic, strong) NSMutableArray *handleDatas;

@property (nonatomic, strong) NSArray *colorArray;

@end

@implementation DoodleBoardConfig

+(instancetype)defaultConfigWithType:(DoodleBoardHandleType)type delegate:(id<DoodleBoardViewDelegate>)delegate{
    
    DoodleBoardConfig *config = [[DoodleBoardConfig alloc]init];
    config.type = type;
    config.delegate = delegate;
    return config;
}

-(void)setType:(DoodleBoardHandleType)type{
    _type = type;
    
    __weak typeof(self) wself = self;
    
    NSMutableArray *handlArray = [NSMutableArray array];
    
    if (type & DoodleBoardHandleEidt) {//编辑
        DoodleBoardBottomHandleModel *editModel = [DoodleBoardBottomHandleModel modelWithTpye:DoodleBoardBottomHandleEidt selectIconName:@"doodleEditSelect" normalIconName:@"doodleEdit" actionBlock:^{
            if ([wself.delegate respondsToSelector:@selector(DoodleBoardViewDidClickEdit)]) {
                [wself.delegate DoodleBoardViewDidClickEdit];
            }
        }];
        [handlArray addObject:editModel];
    }
    
    if (type & DoodleBoardHandleSignature) {//会签
        DoodleBoardBottomHandleModel *signatureModel = [DoodleBoardBottomHandleModel modelWithTpye:DoodleBoardBottomHandleEidt selectIconName:@"doodleTSelect" normalIconName:@"doodleT" actionBlock:^{
            if ([wself.delegate respondsToSelector:@selector(DoodleBoardViewDidClickSignature)]) {
                [wself.delegate DoodleBoardViewDidClickSignature];
            }
        }];
        [handlArray addObject:signatureModel];
    }
    
    if (type & DoodleBoardHandleCode) {//马塞克
        DoodleBoardBottomHandleModel *codeModel = [DoodleBoardBottomHandleModel modelWithTpye:DoodleBoardBottomHandleEidt selectIconName:@"canSee" normalIconName:@"cannotSee" actionBlock:^{
            if ([wself.delegate respondsToSelector:@selector(DoodleBoardViewDidClickCode)]) {
                [wself.delegate DoodleBoardViewDidClickCode];
            }
        }];
        [handlArray addObject:codeModel];
    }
    
    if (type & DoodleBoardHandleTailoring) {//裁剪
        DoodleBoardBottomHandleModel *tailoringModel = [DoodleBoardBottomHandleModel modelWithTpye:DoodleBoardBottomHandleEidt selectIconName:@"" normalIconName:@"tailoring" actionBlock:^{
            if ([wself.delegate respondsToSelector:@selector(DoodleBoardViewDidClickTailoring)]) {
                [wself.delegate DoodleBoardViewDidClickTailoring];
            }
        }];
        [handlArray addObject:tailoringModel];
    }
    _handleDatas = handlArray;
}

/**
 获取底部操作栏数据
 */
-(NSMutableArray<DoodleBoardBottomHandleModel *> *)getBottomHandleDatas{
    return self.handleDatas;
}


/**
 获取顶部操作子项数据
 */
-(NSMutableArray<DoodleBoardBottomHandleModel *> *)getBottomHandleSubDatasWithType:(DoodleBoardBottomHandleType)type{
    __weak typeof(self)wself = self;
    NSMutableArray *temp = [NSMutableArray array];
    if (type == DoodleBoardBottomHandleEidt) {
        NSArray *colorArray = self.colorArray;
        NSLog(@"%@",colorArray);
        for (NSString *color in colorArray) {
            __block DoodleBoardBottomHandleModel *model = [DoodleBoardBottomHandleModel modelWithTpye:DoodleBoardBottomHandleColor selectIconName:@"" normalIconName:@"" actionBlock:^{
                if ([wself.delegate respondsToSelector:@selector(DoodleBoardViewDidChooseColor:)]) {
                    [wself.delegate DoodleBoardViewDidChooseColor:model.colorStr];
                }
            }];
            NSLog(@"%@",model);
            model.colorStr = color;
            [temp addObject:model];
        }
        [temp addObject:[self createUndoModelWithType:DoodleBoardBottomHandleEidt]];
    }else if (type == DoodleBoardBottomHandleCode){
        [temp addObject:[self createUndoModelWithType:DoodleBoardBottomHandleCode]];
    }else if (type == DoodleBoardBottomHandleSignature){
        [temp addObject:[self createUndoModelWithType:DoodleBoardBottomHandleSignature]];
    }
    return temp;
}

/**
 撤销
 */
-(DoodleBoardBottomHandleModel *)createUndoModelWithType:(DoodleBoardBottomHandleType)type{
     __weak typeof(self)wself = self;
    
    NSString *iconName = @"";
    NSString *iconSelName = @"";
    
    if (type == DoodleBoardBottomHandleEidt) {
        iconName = @"undo_draft_enable";
        iconSelName = @"undo_draft";
    }else if (type == DoodleBoardBottomHandleCode){
        iconName = @"delete_draft_enable";
        iconSelName = @"delete_draft";
    }else if (type == DoodleBoardBottomHandleSignature){
        iconName = @"undo_draft_enable";
        iconSelName = @"undo_draft";
    }
    
    DoodleBoardBottomHandleModel *model = [DoodleBoardBottomHandleModel modelWithTpye:DoodleBoardBottomHandleCancel selectIconName:iconSelName normalIconName:iconName actionBlock:^{
        if ([wself.delegate respondsToSelector:@selector(DoodleBoardViewDidClickUndo:)]) {
            [wself.delegate DoodleBoardViewDidClickUndo:type];
        }
    }];
    return model;
}

-(NSArray *)colorArray{
    if (!_colorArray) {
        _colorArray = @[
                        @"FFFFFF",
                        @"000000",
                        @"FF0000",
                        @"FFFF00",
                        @"008000",
                        @"0000FF",
                        @"800080"
                        ];
    }
    return _colorArray;
}


@end
