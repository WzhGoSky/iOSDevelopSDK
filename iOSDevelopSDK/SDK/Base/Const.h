//
//  Const.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/27.
//  Copyright © 2019 Hayder. All rights reserved.
//

#ifndef Const_h
#define Const_h

// 生产 / 测试 环境切换
//  0是发布状态 , 1 是测试状态，, 2是线上测试
#ifdef DEBUG
// 调试状态
#define SFDEBUG 1

#else
// 发布状态
#define SFDEBUG 0

#endif

#pragma mark ---------------------SDK_Key----------------------------

#endif
