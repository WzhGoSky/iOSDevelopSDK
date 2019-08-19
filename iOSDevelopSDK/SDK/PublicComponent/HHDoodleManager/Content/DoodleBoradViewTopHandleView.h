//
//  DoodleBoradViewTopHandleView.h
//  AFNetworking
//
//  Created by Hayder on 2019/2/22.
//    顶部完成&取消 事件栏目

#import <UIKit/UIKit.h>

@protocol DoodleBoradViewTopHandleViewDelegate <NSObject>

/**
 取消事件
 */
-(void)doodleBoradViewTopHandleViewDidCacnel:(UIButton *)btn;

/**
 完成事件
 */
-(void)doodleBoradViewTopHandleViewDidFinfish:(UIButton *)btn;

@end

@interface DoodleBoradViewTopHandleView : UIView

@property (nonatomic, weak) id<DoodleBoradViewTopHandleViewDelegate> delegate;

@end
