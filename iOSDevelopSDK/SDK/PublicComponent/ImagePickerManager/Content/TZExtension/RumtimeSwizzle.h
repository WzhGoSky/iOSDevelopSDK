//
//  RumtimeSwizzle.h
//  test
//
//  Created by Hayder on 2018/10/6.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RumtimeSwizzle : NSObject

+ (void)_methodSwizzleAClass:(Class)aClass Selector:(SEL)aSel  Selector:(SEL)bSel isClassMethod:(BOOL)classMethod;
+ (id)_getPrivateProperty:(Class)aClass  name:(NSString *)propertyName;
@end
