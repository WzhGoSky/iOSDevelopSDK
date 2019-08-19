//
//  NSObject+AutoProperty.h
//  JYQX
//
//  Created by Hayder on 2018/9/7.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AutoProperty)

/**
 *  自动生成属性列表
 *
 *  @param dict JSON字典/模型字典
 */
+(void)printPropertyWithDict:(NSDictionary *)dict;

@end
