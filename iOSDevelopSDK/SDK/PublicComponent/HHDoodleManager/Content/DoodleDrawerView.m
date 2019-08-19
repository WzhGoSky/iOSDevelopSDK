//
//  DoodleDrawerView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/4.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "DoodleDrawerView.h"
#import "DoodleDrawerPaintPath.h"
#import "DrawingHelper.h"

@interface DoodleDrawerView()

@property (nonatomic, strong)DoodleDrawerPaintPath * path;
@property (nonatomic, strong)CAShapeLayer * slayer;


#pragma 马塞克相关

/** <##> */
@property (nonatomic, strong) CALayer *sexImageLayer;
/** <##> */
@property (nonatomic, strong) CAShapeLayer *sexShapeLayer;
/** 手指的涂抹路径 */
@property (nonatomic, assign) CGMutablePathRef sexPath;

@end

@implementation DoodleDrawerView

- (NSMutableArray *)lines
{
    if (_lines == nil) {
        _lines = [NSMutableArray array];
    }
    return _lines;
}

-(DoodleDrawerPaintPath *)getDrawPath{
    return self.path;
}


- (NSMutableArray *)canceledLines
{
    if (_canceledLines == nil) {
        _canceledLines = [NSMutableArray array];
    }
    return _canceledLines;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.canDrawer = YES;
        self.lineWidth = 6;
        self.lineColor = [UIColor redColor];
        self.userInteractionEnabled = YES;
        
        self.sexPath = CGPathCreateMutable();
    }
    return self;
}

// 根据touches集合获取对应的触摸点
- (CGPoint)pointWithTouches:(NSSet *)touches
{
   
    UITouch *touch = [touches anyObject];
    
    return [touch locationInView:self];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    if (self.type == DoodleDrawerViewSex) {
     
        [super touchesBegan:touches withEvent:event];
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGPathMoveToPoint(self.sexPath, nil, point.x, point.y);
        self.sexShapeLayer.path = self.sexPath;
        self.canUndoSex = YES;
        return;
    }
    
    if (!self.canDrawer) {return;}
    CGPoint startP = [self pointWithTouches:touches];
    
    
    if ([event allTouches].count == 1) {
        
        DoodleDrawerPaintPath *path = [DoodleDrawerPaintPath paintPathWithLineWidth:self.lineWidth
                                                       startPoint:startP];
        _path = path;
        
        CAShapeLayer * slayer = [CAShapeLayer layer];
        slayer.path = path.CGPath;
        slayer.backgroundColor = [UIColor clearColor].CGColor;
        slayer.fillColor = [UIColor clearColor].CGColor;
        slayer.lineCap = kCALineCapRound;
        slayer.lineJoin = kCALineJoinRound;
        slayer.strokeColor = self.lineColor.CGColor;
        slayer.lineWidth = path.lineWidth;
        [self.layer addSublayer:slayer];
        _slayer = slayer;
        [[self mutableArrayValueForKey:@"canceledLines"] removeAllObjects];
        [[self mutableArrayValueForKey:@"lines"] addObject:_slayer];
        
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    if (self.type == DoodleDrawerViewSex) {
        [super touchesMoved:touches withEvent:event];
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGPathAddLineToPoint(self.sexPath, nil, point.x, point.y);
        self.sexShapeLayer.path = self.sexPath;
        self.canUndoSex = YES;
        return;
    }
    
    if (!self.canDrawer) {return;}
    // 获取移动点
    CGPoint moveP = [self pointWithTouches:touches];
    
    if ([event allTouches].count > 1){
        
        [self.superview touchesMoved:touches withEvent:event];
        
    }else if ([event allTouches].count == 1) {
        
        [_path addLineToPoint:moveP];

        _slayer.path = _path.CGPath;

    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    if (!self.canDrawer) {return;}
    
    if (self.type == DoodleDrawerViewSex ) {
        [super touchesEnded:touches withEvent:event];
    }
    
    if ([event allTouches].count > 1){
        [self.superview touchesMoved:touches withEvent:event];
    }
}

-(void)dealloc{
    if (self.sexPath) {
        CGPathRelease(self.sexPath);
    }
}

/**
 马塞克清除
 */
-(void)clearSex{
    CGPathRelease(self.sexPath);
    self.sexPath = CGPathCreateMutable();
    self.sexShapeLayer.path = nil;
    self.sexImageLayer = nil;
    self.sexShapeLayer = nil;
    self.canUndoSex = NO;
}

/**
 *  画线
 */
- (void)drawLine{
    
    [self.layer addSublayer:self.lines.lastObject];
    
}

/**
 *  清屏
 */
- (void)clearScreen
{
    
    if (self.type == DoodleDrawerViewSex) {
        CGPathRelease(self.sexPath);
        self.sexPath = CGPathCreateMutable();
        self.sexShapeLayer.path = nil;
        return;
    }
    
    
    if (!self.lines.count) return ;
    
    [self.lines makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [[self mutableArrayValueForKey:@"lines"] removeAllObjects];
    [[self mutableArrayValueForKey:@"canceledLines"] removeAllObjects];
    
}

/**
 *  撤销
 */
- (void)undo
{
    //当前屏幕已经清空，就不能撤销了
    if (!self.lines.count) return;
    [[self mutableArrayValueForKey:@"canceledLines"] addObject:self.lines.lastObject];
    [self.lines.lastObject removeFromSuperlayer];
    [[self mutableArrayValueForKey:@"lines"] removeLastObject];
    
}


/**
 *  恢复
 */
- (void)redo
{
    //当没有做过撤销操作，就不能恢复了
    if (!self.canceledLines.count) return;
    [[self mutableArrayValueForKey:@"lines"] addObject:self.canceledLines.lastObject];
    [[self mutableArrayValueForKey:@"canceledLines"] removeLastObject];
    [self drawLine];
    
}


/**
 获取编辑图片
 */
-(UIImage *)getEidtImg{
    return  [self imageWithCaputureView:self];
}

// 控件截屏
- (UIImage *)imageWithCaputureView:(UIView *)view
{
    // 开启位图上下文
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    
    // 获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 把控件上的图层渲染到上下文,layer只能渲染
    [view.layer renderInContext:ctx];
    
    // 生成一张图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)refreshSexImg{
    self.sexImageLayer = nil;
}

/**
 是否编辑过
 */
-(BOOL)isEdit{
    
    if (self.type == DoodleDrawerViewSex ) {
        return  self.sexShapeLayer.path != nil;
    }else{
        return (BOOL)self.lines.count;
    }
}

-(void)hiddenLayer{
    for (CALayer *subLayer in self.layer.sublayers) {
        subLayer.hidden = YES;
    }
}

-(void)showLayer{
    for (CALayer *subLayer in self.layer.sublayers) {
        subLayer.hidden = NO;
    }
}

-(void)setImage:(UIImage *)image{
    [super setImage:image];
    self.sexImageLayer = nil;
    self.sexShapeLayer = nil;
    self.sexPath = CGPathCreateMutable();
    self.sexShapeLayer.path = nil;
}

-(CALayer *)sexImageLayer{
    if (!_sexImageLayer) {
        _sexImageLayer = [CALayer layer];
        _sexImageLayer.frame = self.bounds;
        _sexImageLayer.contents = (id)[DrawingHelper getMosaicImageWith:self.image level:0].CGImage;
        [self.layer addSublayer:_sexImageLayer];
        [self.layer insertSublayer:_sexImageLayer atIndex:0];
    }
    return _sexImageLayer;
}

-(CAShapeLayer *)sexShapeLayer{
    if (!_sexShapeLayer) {
        _sexShapeLayer = [CAShapeLayer layer];
        _sexShapeLayer.frame = self.bounds;
        _sexShapeLayer.lineCap = kCALineCapRound;
        _sexShapeLayer.lineJoin = kCALineJoinRound;
        _sexShapeLayer.lineWidth = 6;
        _sexShapeLayer.strokeColor = [UIColor blueColor].CGColor;
        _sexShapeLayer.fillColor = nil;//此处必须设为nil，否则后边添加addLine的时候会自动填充
        self.sexImageLayer.mask = _sexShapeLayer;
    }
    return _sexShapeLayer;
}



/**
 刷新位置
 */
-(void)refreshPathWithOldFrame:(CGRect)oldFrame newFrame:(CGRect)newFrame{
    CGFloat x = oldFrame.origin.x - newFrame.origin.x;
    CGFloat y = oldFrame.origin.y - newFrame.origin.y;
    
    NSLog(@"old :  x =   %f    ,   y  =  %f  ,   width = %f    ,   height  = %f  ", oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
    
    
    NSLog(@"new :  x =   %f    ,   y  =  %f  ,   width = %f    ,   height  = %f  ", newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height);
    
    
    CGAffineTransform translation = CGAffineTransformMakeTranslation(x, y);
    
    CGPathRef movedPath = CGPathCreateCopyByTransformingPath(self.path.CGPath, &translation);
    
    DoodleDrawerPaintPath * path = [[DoodleDrawerPaintPath alloc] init];
    path.lineWidth = self.lineWidth;
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    path.CGPath = movedPath;
    
    self.path = path;
    self.slayer.path = self.path.CGPath;
    
    [self refreshLinesWithArray:self.lines translation:&translation];
    [self refreshLinesWithArray:self.canceledLines translation:&translation];

}

-(void)refreshLinesWithArray:(NSArray *)layers translation:(CGAffineTransform * __nullable)transform{
    for (CAShapeLayer *layer in layers) {
        
        CGPathRef oldPath = layer.path;
        
        CGPathRef movedPath1 = CGPathCreateCopyByTransformingPath(oldPath, transform);
        DoodleDrawerPaintPath * path = [[DoodleDrawerPaintPath alloc] init];
        path.lineWidth = self.lineWidth;
        path.lineCapStyle = kCGLineCapRound; //线条拐角
        path.lineJoinStyle = kCGLineCapRound; //终点处理
        path.CGPath = movedPath1;
        
        layer.path = movedPath1;
    }
    
}



@end
