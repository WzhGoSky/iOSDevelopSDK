//
//  DoodleBoardClipAreaLayer.m
//  AFNetworking
//
//  Created by Hayder on 2019/4/12.
//

#import "DoodleBoardClipAreaLayer.h"
#import <UIKit/UIKit.h>
#import "globalDefine.h"
static CGFloat const lineWidth = 3;
@implementation DoodleBoardClipAreaLayer
- (instancetype)init
{
    self = [super init];
    if (self) {
        _cropAreaLeft = 50;
        _cropAreaTop = 50;
        _cropAreaRight = SCREEN_WIDTH - self.cropAreaLeft;
        _cropAreaBottom = 400;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    CGFloat w = 0;
    CGFloat h = 0;
    
//    if (self.configModel.bgDiagonalIcon) {
//        w = self.configModel.bgDiagonalIcon.size.width;
//        h = self.configModel.bgDiagonalIcon.size.height;
//    }
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaLeft + w * 0.5, self.cropAreaTop + h * 0.5);
    CGContextAddLineToPoint(ctx, self.cropAreaLeft + w * 0.5, self.cropAreaBottom - h * 0.5);
    CGContextSetShadow(ctx, CGSizeMake(2, 0), 2.0);
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaLeft + w * 0.5, self.cropAreaTop + h * 0.5);
    CGContextAddLineToPoint(ctx, self.cropAreaRight - w * 0.5, self.cropAreaTop + h * 0.5);
    CGContextSetShadow(ctx, CGSizeMake(0, 2), 2.0);
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaRight - w * 0.5, self.cropAreaTop + h * 0.5);
    CGContextAddLineToPoint(ctx, self.cropAreaRight - w * 0.5, self.cropAreaBottom - h * 0.5);
    CGContextSetShadow(ctx, CGSizeMake(-2, 0), 2.0);
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaLeft + w * 0.5, self.cropAreaBottom - h * 0.5);
    CGContextAddLineToPoint(ctx, self.cropAreaRight - w * 0.5, self.cropAreaBottom - h * 0.5);
    CGContextSetShadow(ctx, CGSizeMake(0, -2), 2.0);
    CGContextStrokePath(ctx);
    
//    if (self.configModel.bgDiagonalIcon) {
//        [self.configModel.bgDiagonalIcon drawAtPoint:CGPointMake(self.cropAreaLeft, self.cropAreaTop)];
//        [self.configModel.bgDiagonalIcon drawAtPoint:CGPointMake(self.cropAreaRight - w, self.cropAreaBottom - h)];
//    }
    
    UIGraphicsPopContext();
}

- (void)setCropAreaLeft:(NSInteger)cropAreaLeft
{
    _cropAreaLeft = cropAreaLeft;
    [self setNeedsDisplay];
}

- (void)setCropAreaTop:(NSInteger)cropAreaTop
{
    _cropAreaTop = cropAreaTop;
    [self setNeedsDisplay];
}

- (void)setCropAreaRight:(NSInteger)cropAreaRight
{
    _cropAreaRight = cropAreaRight;
    [self setNeedsDisplay];
}

- (void)setCropAreaBottom:(NSInteger)cropAreaBottom
{
    _cropAreaBottom = cropAreaBottom;
    [self setNeedsDisplay];
}

- (void)setCropAreaLeft:(NSInteger)cropAreaLeft CropAreaTop:(NSInteger)cropAreaTop CropAreaRight:(NSInteger)cropAreaRight CropAreaBottom:(NSInteger)cropAreaBottom configModel:(DoodleBoardClipConfigModel *)configModel
{
    _cropAreaLeft = cropAreaLeft;
    _cropAreaRight = cropAreaRight;
    _cropAreaTop = cropAreaTop;
    _cropAreaBottom = cropAreaBottom;
    _configModel = configModel;
    
    [self setNeedsDisplay];
}
@end
