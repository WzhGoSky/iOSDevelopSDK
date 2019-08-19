//
//  HHVideoClipSliderBlockBtn.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/26.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHVideoClipSliderBlockBtn.h"
#import "UIView+HHAdditions.h"


@implementation HHVideoClipSliderBlockBtn

#pragma mark - life cycle
- (void)drawRect:(CGRect)rect {
    
    if (self.sliderImage) {
        
        [self.sliderImage drawInRect:self.bounds];
        
    }else {
        
        UIRectCorner rectCorner;
        
        if (self.isLeftSliderBtn) {
            
            rectCorner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
            
        }else {
            
            rectCorner = UIRectCornerTopRight | UIRectCornerBottomRight;
        }
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(4, 4)];
        [path addClip];
        [[UIColor colorWithRed:170 green:170 blue:170 alpha:1] set];
        [path fill];
        UIBezierPath *verticalLine = [UIBezierPath bezierPathWithRect:CGRectMake(self.width * 0.5, 10, 1, self.height - 20)];
        [[UIColor grayColor] set];
        [verticalLine fill];
        
    }
}

@end
