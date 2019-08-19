//
//  DoodleBoardView.h
//  AFNetworking
//
//  Created by Hayder on 2019/2/22.
//  仿微信 图片涂鸦

#import <UIKit/UIKit.h>
#import "DoodleBoardConfig.h"
#import "DrawingModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    DoodleBoardViewNormal,
    DoodleBoardViewEdit,
} DoodleBoardViewType;

@interface DoodleBoardView : UIView

@property (nonatomic, assign) DoodleBoardViewType boardType;

/**
 混合模式
 */
@property (nonatomic, assign) BOOL isHybrid;

@property (nonatomic, strong) void(^stateChangeBlock)(BOOL isNoraml);

/**
 涂鸦板
 img ：数据源
 type：
         DoodleBoardHandleEidt                                                         = 1 << 0,//编辑
         DoodleBoardHandleSignature                                                    = 1 << 1,//会签
         DoodleBoardHandleTailoring                                                  = 1 << 2,//裁剪
         DoodleBoardHandleCode                                                       = 1 << 3,//马塞克
 cancelBlock：  取消
 complete ： 完成
 */
+(void)showDoodleBoardViewWithNeedEditImg:(UIImage *)img type:(DoodleBoardHandleType)type cancelBlock:(void(^)(void))cancelBlock complete:(void(^)(UIImage *img))complete;
+(void)showDoodleBoardViewWithNeedEditImg:(UIImage *)img type:(DoodleBoardHandleType)type inView:(UIView *)superView cancelBlock:(void(^)(void))cancelBlock complete:(void(^)(UIImage *img))complete;


@end



@protocol DoodleBoardViewCellDelegate <NSObject>

-(void)DoodleBoardViewCellDidChangeState:(BOOL)isNormal;

@end


@interface DoodleBoardViewCell :UICollectionViewCell

@property (nonatomic, strong) DrawingModel *model;

@property (nonatomic, assign) DoodleBoardHandleType type;

@property (nonatomic, assign) DoodleBoardViewType boardType;

@property (nonatomic, weak) id<DoodleBoardViewCellDelegate> delegate;
/**
 混合模式
 */
@property (nonatomic, assign) BOOL isHybrid;

@end

NS_ASSUME_NONNULL_END
