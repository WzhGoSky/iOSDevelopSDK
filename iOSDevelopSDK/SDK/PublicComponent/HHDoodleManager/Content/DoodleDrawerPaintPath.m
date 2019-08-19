//
//  DoodleDrawerPaintPath.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/4.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "DoodleDrawerPaintPath.h"

@implementation DoodleDrawerPaintPath
+ (instancetype)paintPathWithLineWidth:(CGFloat)width startPoint:(CGPoint)startP{
    DoodleDrawerPaintPath * path = [[self alloc] init];
    path.lineWidth = width;
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    [path moveToPoint:startP];
    return path;
}


+(void)refreshDrawerPaintPath:(DoodleDrawerPaintPath *)path oldFrame:(CGRect)oldFrame newFrame:(CGRect)newFrame{
    
    CGFloat x = oldFrame.origin.x - newFrame.origin.x;
    CGFloat y = oldFrame.origin.y - newFrame.origin.y;
    
    NSLog(@"old :  x =   %f    ,   y  =  %f  ,   width = %f    ,   height  = %f  ", oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
    

    NSLog(@"new :  x =   %f    ,   y  =  %f  ,   width = %f    ,   height  = %f  ", newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height);
    
    
    CGAffineTransform translation = CGAffineTransformMakeTranslation(x, - y);
    CGPathRef movedPath = CGPathCreateCopyByTransformingPath(path.CGPath, &translation);
    
    path.CGPath = movedPath;
    
}

@end
