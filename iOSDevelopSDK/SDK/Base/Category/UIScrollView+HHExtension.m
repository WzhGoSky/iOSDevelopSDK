//
//  UIScrollView+HHExtension.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import "UIScrollView+HHExtension.h"

@implementation UIScrollView (HHExtension)

- (void)neverAdjustmentContentInset
{
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *) ) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
#endif
}

@end
