//
//  UIButton+ShortVideoExtension.m
//  AFNetworking
//
//  Created by Hayder on 2018/10/31.
//

#import "UIButton+ShortVideoExtension.h"

@implementation UIButton (ShortVideoExtension)
- (void)show {
    
    if (!self.hidden) return;
    
    self.hidden = NO;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:2.0];
    scaleAnimation.toValue   = [NSNumber numberWithFloat:1.0];
    scaleAnimation.duration  = .3;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue  = [NSNumber numberWithFloat:.5];
    opacityAnimation.toValue    = [NSNumber numberWithFloat:1];
    opacityAnimation.duration   = .3;
    
    [self.layer addAnimation:scaleAnimation forKey:@"scale"];
    [self.layer addAnimation:opacityAnimation forKey:@"opacity"];
}

- (void)hide {
    self.hidden = YES;
}

@end
