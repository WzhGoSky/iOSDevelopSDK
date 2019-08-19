//
//  HHPaintView.m
//  HHStore
//
//  Created by Hayder on 14/12/23.
//  Copyright (c) 2014年 Hayder. All rights reserved.
//

#import "HHPaintView.h"

@implementation HHPaintView
@synthesize drawingMode = _drawingMode,selectedColor = _selectedColor,viewImage = _viewImage;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self.viewImage drawInRect:self.bounds];
}

- (void)cancelDrawed
{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextClearRect(UIGraphicsGetCurrentContext(), self.bounds);
    UIGraphicsEndImageContext();
}

#pragma mark - setter methods
- (void)setDrawingMode:(DrawingMode)drawingMode
{
    _drawingMode = drawingMode;
}

#pragma mark - Private methods
- (void)initialize
{
    currentPoint   = CGPointMake(0, 0);
    previousPoint  = currentPoint;
    
    // 初始化时，默认可以画图
    _drawingMode = DrawingModePaint;
    
    _selectedColor = [UIColor redColor];
}

- (void)setViewImage:(UIImage *)viewImage
{
    _viewImage = viewImage;
    
    [self setNeedsDisplay];
}

- (void)eraseLine
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.viewImage drawInRect:self.bounds];
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDestinationIn);
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 50);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDestinationIn);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor clearColor].CGColor);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), previousPoint.x, previousPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    _viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    previousPoint  = currentPoint;
    
    [self setNeedsDisplay];
}

- (void)drawLineNew
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeImage" object:nil];
    
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.viewImage drawInRect:self.bounds];
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineJoin(UIGraphicsGetCurrentContext(), kCGLineJoinRound);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.selectedColor.CGColor);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 3);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), previousPoint.x, previousPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    _viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    previousPoint  = currentPoint;
    
    [self setNeedsDisplay];
}



- (void)handleTouches
{
    if (self.drawingMode == DrawingModeNone) {
        // do nothing
    } else if (self.drawingMode == DrawingModePaint) {
        [self drawLineNew];
    } else {
        [self eraseLine];
    }
}



#pragma mark - Touches methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    previousPoint = p;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentPoint = [[touches anyObject] locationInView:self];
    [self handleTouches];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentPoint = [[touches anyObject] locationInView:self];
    
    [self handleTouches];
}


@end
