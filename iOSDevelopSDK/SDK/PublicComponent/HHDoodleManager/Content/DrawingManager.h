//
//  DrawingManager.h
//  PublicComponent
//
//  Created by Hayder on 2018/10/19.
//

#import <UIKit/UIKit.h>
#import "DoodleBoardConfig.h"

@interface DrawingManager : NSObject
///**
// 单张编辑模式
// */
//+(void)showSingleDrawing:(UIImage *)editImg config:(DrawingConfig *)config complete:(void(^)(UIImage *editImg))complete cancelBlock:(void(^)(void))cancelBlock;
//
//
///**
// 多张编辑模式
// */
//+(void)showASetOfImgsDrawing:(NSArray<UIImage *> *)imgArray config:(DrawingConfig *)config complete:(void(^)(NSArray<UIImage *> *editArray))complete;

/**
 单张编辑模式
 */
+(void)showSingleDrawing:(UIImage *)editImg type:(DoodleBoardHandleType)type cancelBlock:(void(^)(void))cancelBlock completeBlock:(void(^)(UIImage *img))complete;

/**
 多张编辑模式
 */
+(void)showASetOfImgsDrawing:(NSArray<UIImage *> *)imgArray type:(DoodleBoardHandleType)type  inView:(UIView *)superView complete:(void(^)(NSArray<UIImage *> *editArray))complete;

@end
