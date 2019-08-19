//
//  DoodleBoardClipHandleView.h
//  AFNetworking
//
//  Created by Hayder on 2019/4/12.
//

#import <UIKit/UIKit.h>
#import "DoodleBoardClipConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoodleBoardClipHandleBottomView : UIView


@property (nonatomic, strong) void(^didClickCloseBlock)(void);
@property (nonatomic, strong) void(^didClickFinishBlock)(void);
@property (nonatomic, strong) void(^didClickTitleBlock)(void);
@end



@interface DoodleBoardClipHandleView : UIView

@end

@interface DoodleBoardClipView : UIView


+(void)showDoodleBoardClipHandleViewWithImg:(UIImage *)img preImg:(UIImage *)preImg superView:(UIView *)superView cancleBlock:(void(^)(void))cancleBlock complete:(void(^)(UIImage *img))complete;


/**
 框的frame
 img
 原图
 取消 & 确定事件
 
 */
+(void)showDoodleBoardClipHandleViewWithImg:(UIImage *)img preImg:(UIImage *)preImg superView:(UIView *)superView frame:(CGRect)frame configModel:(DoodleBoardClipConfigModel *)model;

/**
 取消事件
 */
-(void)dismiss;

/**
 确认事件
 */
-(void)didClickDoneComplete:(void(^)(UIImage *img, UIImage *originalImg, CGRect frame))complete;

@end

NS_ASSUME_NONNULL_END
