//
//  UIScrollView+HHExtension.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (HHExtension)

/** 为适配 iOS11 高度下移问题 */
- (void)neverAdjustmentContentInset;

@end

