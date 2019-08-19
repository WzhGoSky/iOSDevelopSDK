//
//  NSObject+KDDoodleBoardExtension.h
//  AFNetworking
//
//  Created by Hayder on 2019/3/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSObject (DoodleBoardExtension)
/**
 * 获取当前显示的控制器
 */
+ (UIViewController *)getCurrentController;

+ (UIViewController *)getPresentController;
    
@end

NS_ASSUME_NONNULL_END
