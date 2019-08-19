//
//  DoodleBoardColorModel.h
//  AFNetworking
//
//  Created by Hayder on 2019/2/22.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    DoodleBoardBottomHandleColor,//颜色
    DoodleBoardBottomHandleCancel,//撤销
    DoodleBoardBottomHandleCode,//马塞克
    DoodleBoardBottomHandleEidt,//编辑
    DoodleBoardBottomHandleSignature,//会签
    DoodleBoardBottomHandleTailoring//裁剪
} DoodleBoardBottomHandleType;

@interface DoodleBoardBottomHandleModel : NSObject

@property (nonatomic, assign) DoodleBoardBottomHandleType type;

@property (nonatomic, strong) NSString *unSelectIconName;

@property (nonatomic, strong) NSString *selectIconNAme;

/**
 颜色  色值
 */
@property (nonatomic, strong) NSString * colorStr;

/**
 事件
 */
@property (nonatomic, strong) void(^actionBlock)(void);

+(instancetype)modelWithTpye:(DoodleBoardBottomHandleType)type selectIconName:(NSString *)selectIconName normalIconName:(NSString *)normalIconName actionBlock:(void(^)(void))actionBlock;

@end

