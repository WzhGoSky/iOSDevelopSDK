//
//  HHRotationManager.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HHRotationManager : NSObject

@property (nonatomic,assign) BOOL allowRotation;//横竖屏

+ (instancetype)manager;


/**强制横屏*/
+ (void)rotationLandscape;

/**强制竖屏*/
+ (void)rotationPortrait;

/**是否是竖屏*/
+ (BOOL)isPortrait;

@end

