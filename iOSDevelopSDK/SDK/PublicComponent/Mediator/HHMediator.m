//
//  WDZMediator.m
//  WDZForAppStore
//
//  Created by Hayder on 2019/3/8.
//  Copyright © 2019年 Hayder. All rights reserved.
//

#import "HHMediator.h"
#import "Target_NotFound.h"

@interface HHMediator()

// 增加缓存 避免高频调用
@property (nonatomic,strong) NSMutableDictionary * targetCaches;
@end

@implementation HHMediator

#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static HHMediator *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[HHMediator alloc] init];
        
        mediator->_willPresentControllers = [NSArray array];
    });
    return mediator;
}

/*
 scheme://[target]/[action]?[params]
 url sample:
 aaa://targetA/actionB?id=1234
 */

- (id)performActionWithUrl:(NSURL *)url completion:(void (^)(NSDictionary *))completion
{
    
    if (![url.scheme isEqualToString:@""]) {
        // 这里就是针对远程app调用404的简单处理了，根据不同app的产品经理要求不同，你们可以在这里自己做需要的逻辑
        return @(NO);
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *urlString = [url query];
    for (NSString *param in [urlString componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:[elts lastObject] forKey:[elts firstObject]];
    }
    
    // 这里这么写主要是出于安全考虑，防止别人通过远程方式调用本地模块。这里的做法足以应对绝大多数场景，如果要求更加严苛，也可以做更加复杂的安全逻辑。
    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    // 针对URL的路由处理非常简单，就只是取对应的target名字和method名字，但这已经足以应对绝大部份需求。如果需要拓展，可以在这个方法调用之前加入完整的路由逻辑
    UIViewController * root = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    id result = @"error";
    if ([root isKindOfClass:NSClassFromString(@"UIViewController")]) {
        result = [self performTarget:url.host action:actionName params:params shouldCacheTarget:NO]; // 只有root是这两个控制器的时候适合直接打开
    } else {
        result = url; //其余都走url进行跳转打开
    }

    if (completion) {
        if (result) {
            completion(@{@"result":result});
        } else {
            completion(nil);
        }
    }
    return result;
}


/**
 targetName:
 actionName:
 params:
 shouldCacheTarget:
 */
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget
{
    //跳转到身份
    NSString *targetClassString = [NSString stringWithFormat:@"Target_%@", targetName];
    NSString *actionString = [NSString stringWithFormat:@"Action_%@:", actionName];
    
    //看下缓存中是否有
    id target = self.targetCaches[targetClassString];
    if (target == nil) {
        Class targetClass = NSClassFromString(targetClassString);
        target = [[targetClass alloc] init];
    }
    
    SEL action = NSSelectorFromString(actionString);
    
    if (target == nil) {
        // 这里是处理无响应请求的地方之一，做得比较简单，如果没有可以响应的target，就直接return了。实际开发过程中是可以事先给一个固定的target专门用于在这个时候顶上，然后处理这种请求的
        target = [[Target_NotFound alloc] init];
        [target performSelector:@selector(targetNotFundation:) withObject:@{@"targetName":targetName,
                                                                            @"actionName":actionName
                                                                            }];
        return nil;
    }
    
    if (shouldCacheTarget) {
        self.targetCaches[targetClassString] = target;
    }
    
    if ([target respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
    } else {
        // 这里是处理无响应请求的地方，如果无响应，则尝试调用对应target的notFound方法统一处理
        SEL action = NSSelectorFromString(@"Action_NotFound:");
        if ([target respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
        } else {
            // 这里也是处理无响应请求的地方，在notFound都没有的时候，这里是直接return了。实际开发过程中，可以用前面提到的固定的target顶上的。
            return nil;
        }
    }
}

- (void)releaseCacheWithTargetName:(NSString *)targetName
{
    NSString *targetClassString = [NSString stringWithFormat:@"Target_%@", targetName];
    [self.targetCaches removeObjectForKey:targetClassString];
}

#pragma mark getter
- (NSMutableDictionary *)targetCaches {
    if (!_targetCaches) {
        _targetCaches = [NSMutableDictionary dictionary];
    }
    return _targetCaches;
}


@end
