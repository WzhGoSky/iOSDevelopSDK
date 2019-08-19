//
//  DoodleBoardClipConfigModel.m
//  DynamicClipImage
//
//  Created by 夏征宇 on 2019/4/25.
//  Copyright © 2019 yasic. All rights reserved.
//

#import "DoodleBoardClipConfigModel.h"

@implementation DoodleBoardClipConfigModel


-(instancetype)initWithTop:(float)top withLeft:(float)left withBottom:(float)bottom withRight:(float)right layerBgColor:(UIColor *)layerBgColor tintColor:(UIColor *)tintColor isShowHandle:(BOOL)isShowHandle{
    self = [super init];
    if (self) {
        self.top = top;
        self.left = left;
        self.bottom = bottom;
        self.right = right;
        self.layerBgColor = layerBgColor;
        self.tintColor = tintColor;
        self.isShowHandle = isShowHandle;
    }
    return self;
}

-(instancetype)initWithTop:(float)top withLeft:(float)left withBottom:(float)bottom withRight:(float)right
{
    self = [super init];
    if (self) {
        self.top = top;
        self.left = left;
        self.bottom = bottom;
        self.right = right;
    }
    return self;
}

@end
