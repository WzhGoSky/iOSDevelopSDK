//
//  DoodleBoardConfig.h
//  AFNetworking
//
//  Created by Hayder on 2019/3/6.
//

#import <Foundation/Foundation.h>
#import "DoodleBoardBottomHandleModel.h"

typedef NS_OPTIONS(NSUInteger,DoodleBoardHandleType) {
    DoodleBoardHandleEidt                                                         = 1 << 0,//编辑
    DoodleBoardHandleSignature                                                    = 1 << 1,//会签
    DoodleBoardHandleTailoring                                                  = 1 << 2,//裁剪
    DoodleBoardHandleCode                                                       = 1 << 3,//马塞克
};


@protocol DoodleBoardViewDelegate <NSObject>

/**
 编辑
 */
-(void)DoodleBoardViewDidClickEdit;

/**
 会签
 */
-(void)DoodleBoardViewDidClickSignature;

/**
 马塞克
 */
-(void)DoodleBoardViewDidClickCode;

/**
 裁剪
 */
-(void)DoodleBoardViewDidClickTailoring;


/**
 点击颜色
 */
-(void)DoodleBoardViewDidChooseColor:(NSString *)color;

/**
 撤销
 */
-(void)DoodleBoardViewDidClickUndo:(DoodleBoardBottomHandleType)type;

@end



@interface DoodleBoardConfig : NSObject

/**
 底部事件
 */
@property (nonatomic, assign) DoodleBoardHandleType type;

@property (nonatomic, weak) id<DoodleBoardViewDelegate> delegate;

+(instancetype)defaultConfigWithType:(DoodleBoardHandleType)type delegate:(id<DoodleBoardViewDelegate>)delegate;

/**
 获取底部操作栏数据
 */
-(NSMutableArray<DoodleBoardBottomHandleModel *> *)getBottomHandleDatas;

/**
 获取顶部操作子项数据
 */
-(NSMutableArray<DoodleBoardBottomHandleModel *> *)getBottomHandleSubDatasWithType:(DoodleBoardBottomHandleType)type;

@end


