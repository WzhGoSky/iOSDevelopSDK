//
//  DoodleDrawerPaintPath.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/4.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoodleDrawerPaintPath : UIBezierPath
+ (instancetype)paintPathWithLineWidth:(CGFloat)width
                            startPoint:(CGPoint)startP;

+(void)refreshDrawerPaintPath:(DoodleDrawerPaintPath *)path oldFrame:(CGRect)oldFrame newFrame:(CGRect)newFrame;
@end
