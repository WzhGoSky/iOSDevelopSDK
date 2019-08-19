//
//  RumtimeSwizzle.m
//  test
//
//  Created by Hayder on 2018/10/6.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "RumtimeSwizzle.h"
#import <objc/runtime.h>

@implementation RumtimeSwizzle

+(id)_getPrivateProperty:(Class)aClass  name:(NSString *)propertyName{    
    Ivar iVar = class_getInstanceVariable(aClass, [propertyName UTF8String]);
    NSLog(@"%s ---- %s",ivar_getName(iVar),ivar_getTypeEncoding(iVar));
    if (iVar == nil) {
        iVar = class_getInstanceVariable(aClass, [[NSString stringWithFormat:@"_%@",propertyName] UTF8String]);
    }
    id propertyVal = object_getIvar(aClass, iVar);
    return propertyVal;
}

+ (void)_methodSwizzleAClass:(Class)aClass Selector:(SEL)aSel  Selector:(SEL)bSel isClassMethod:(BOOL)classMethod{
    Method originalMethod;
    Method swizzledMethod;
    
    if (classMethod) {
        originalMethod = class_getClassMethod(aClass, aSel);
        swizzledMethod = class_getClassMethod(aClass, bSel);
    } else {
        originalMethod = class_getInstanceMethod(aClass, aSel);
        swizzledMethod = class_getInstanceMethod(aClass, bSel);
    }
    
    BOOL success = class_addMethod(aClass, aSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(aClass, bSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

@end
