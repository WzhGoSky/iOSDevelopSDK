//
//  HHVideoMapSquareView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/7/31.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHVideoMapSquareView.h"
#import "UIView+HHAdditions.h"
#import "globalDefine.h"

@implementation HHVideoMapSquareView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    UIColor *lineColor;
    if (self.squareColor) {
        lineColor = self.squareColor;
    }else {
        lineColor = [UIColor whiteColor];
    }
    
    // 4个方块
    CGFloat litteSquareW = 5;
//    CGFloat marginLine = litteSquareW / 2;
    
    [self addSquareViewFillColor:lineColor viewRect:CGRectMake(0, 0, litteSquareW, litteSquareW) cornerRadius:0];
    [self addSquareViewFillColor:lineColor viewRect:CGRectMake(self.width - litteSquareW, 0, litteSquareW, litteSquareW) cornerRadius:0];
    [self addSquareViewFillColor:lineColor viewRect:CGRectMake(0, self.height - litteSquareW, litteSquareW, litteSquareW) cornerRadius:0];
    [self addSquareViewFillColor:lineColor viewRect:CGRectMake(self.width - litteSquareW, self.height - litteSquareW, litteSquareW, litteSquareW) cornerRadius:0];
    
    // 4条线
    [self addLineFillColor:lineColor viewRect:CGRectMake(litteSquareW, litteSquareW * 0.5, self.width - litteSquareW * 2, 1)];
    [self addLineFillColor:lineColor viewRect:CGRectMake(litteSquareW * 0.5, litteSquareW, 1, self.height - litteSquareW * 2)];
    [self addLineFillColor:lineColor viewRect:CGRectMake(litteSquareW, self.height - litteSquareW * 0.5, self.width - litteSquareW * 2, 1)];
    [self addLineFillColor:lineColor viewRect:CGRectMake(self.width - litteSquareW * 0.5, litteSquareW, 1, self.height - litteSquareW * 2)];
}

- (void)addSquareViewFillColor:(UIColor *)color viewRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius {
    
    UIBezierPath *topRightSquare = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    [color setFill];
    [topRightSquare fill];
}

- (void)addLineFillColor:(UIColor *)color viewRect:(CGRect)rect {
    
    UIBezierPath *topRightSquare = [UIBezierPath bezierPathWithRect:rect];
    [color setFill];
    [topRightSquare fill];
}

@end
