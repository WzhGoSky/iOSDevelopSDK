//
//  DoodleBoardViewBottomColorView.h
//  AFNetworking
//
//  Created by Hayder on 2019/2/22.
//

#import <UIKit/UIKit.h>
@class DoodleBoardBottomHandleModel;

@interface DoodleBoardViewBottomColorView : UIView

@property (nonatomic, assign) BOOL undoState;

/**
 颜色数组
 */
@property (nonatomic, strong) NSMutableArray<DoodleBoardBottomHandleModel *> *handeDatas;


@end


