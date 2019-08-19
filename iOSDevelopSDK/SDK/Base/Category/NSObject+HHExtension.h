//
//  NSObject+HHExtension.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/27.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (HHExtension)

//导航栏高度
- (CGFloat)navBarHeight;

//tabbar高度
- (CGFloat)tabBarHeight;

/**安全高度: 刘海屏 30 非刘海屏 0*/
- (CGFloat)safeHeight;


@end

NS_ASSUME_NONNULL_END
