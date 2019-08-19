//
//  WDZMediator.h
//  WDZForAppStore
//
//  Created by Hayder on 2019/3/8.
//  Copyright © 2019年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHMediator : NSObject
/** 数组存放提前初始化好的控制器 适合哪些不需要做im登录的控制器使用 */
@property (nonatomic,copy,readonly) NSArray<UIViewController *>* willPresentControllers;
/** 该字段会在初始化完毕之后调用*/
@property (nonatomic,copy,readonly) NSURL * tempURL;

+ (instancetype)sharedInstance;

// 远程App调用入口
- (id)performActionWithUrl:(NSURL *)url completion:(void(^)(NSDictionary *info))completion;
// 本地组件调用入口
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget;

- (void)releaseCacheWithTargetName:(NSString *)targetName;
@end

