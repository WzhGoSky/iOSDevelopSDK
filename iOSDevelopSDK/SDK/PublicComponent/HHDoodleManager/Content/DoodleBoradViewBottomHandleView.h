//
//  DoodleBoradViewBottomHandleView.h
//  AFNetworking
//
//  Created by Hayder on 2019/2/22.
//    底部 编辑事件栏目

#import <UIKit/UIKit.h>
@class DoodleBoardBottomHandleModel;

@interface DoodleBoradViewBottomHandleView : UIView

/**
 底部操作数据
 */
@property (nonatomic, strong) NSMutableArray <DoodleBoardBottomHandleModel *>*handlDatas;

@end
