//
//  DrawingBoard.h
//  PublicComponent
//
//  Created by Hayder on 2018/10/19.
//

#import <UIKit/UIKit.h>
#import "DoodleBoardConfig.h"

@interface DrawingBoard : UIView

+(void)showASetOfImgsDrawing:(NSArray<UIImage *> *)imgArray type:(DoodleBoardHandleType)type inView:(UIView *)superView complete:(void(^)(NSArray<UIImage *> *editArray))complete;

@end
