//
//  DrawingManager.m
//  PublicComponent
//
//  Created by Hayder on 2018/10/19.
//

#import "DrawingManager.h"
#import "DoodleBoardView.h"
#import "DrawingBoard.h"
#import "globalDefine.h"

@implementation DrawingManager

/**
 单张编辑模式
 */
+(void)showSingleDrawing:(UIImage *)editImg type:(DoodleBoardHandleType)type cancelBlock:(void(^)(void))cancelBlock completeBlock:(void(^)(UIImage *img))complete{
    [editImg fixOrientation];
    [DoodleBoardView showDoodleBoardViewWithNeedEditImg:editImg type:type cancelBlock:cancelBlock complete:complete];
}

/**
 多张编辑模式
 */
+(void)showASetOfImgsDrawing:(NSArray<UIImage *> *)imgArray type:(DoodleBoardHandleType)type inView:(UIView *)superView complete:(void(^)(NSArray<UIImage *> *editArray))complete{
    for (UIImage *subImg in imgArray) {
        [subImg fixOrientation];
    }
    [DrawingBoard showASetOfImgsDrawing:imgArray type:type inView:superView complete:complete];
}

@end
