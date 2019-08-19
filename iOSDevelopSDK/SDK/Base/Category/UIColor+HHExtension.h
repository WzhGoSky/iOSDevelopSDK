//
//  UIColor+Extension.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (HHExtension)

/**十六进制方法*/
+ (UIColor *)colorWithHexString: (NSString *)color;

@end

NS_ASSUME_NONNULL_END
