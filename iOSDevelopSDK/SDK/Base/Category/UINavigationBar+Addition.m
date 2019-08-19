//
//  UINavigationBar+Addition.m
//  iOSDevelopSDK
//
//  Created by Tenney on 2018/5/13.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "UINavigationBar+Addition.h"

@implementation UINavigationBar (Addition)

- (void)hideBottomHairline {
    UIImageView *navBarHairlineImageView = [self findHairlineImageViewUnder:self];
    navBarHairlineImageView.hidden = YES;
}

- (void)showBottomHairline {
    UIImageView *navBarHairlineImageView = [self findHairlineImageViewUnder:self];
    navBarHairlineImageView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    navBarHairlineImageView.hidden = NO;
}


- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

@end
