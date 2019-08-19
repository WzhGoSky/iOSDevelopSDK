//
//  QXNavigationController.m
//  JYQX
//
//  Created by Hayder on 2018/8/20.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHNavigationController.h"
#import "UINavigationBar+Addition.h"

#define TitleColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]

@interface HHNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation HHNavigationController

// 只初始化一次
+ (void)initialize
{
    // 设置项目中item的主题样式
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    
    // Normal
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = TitleColor;
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    // 不可用状态
    NSMutableDictionary *disableTextAttrs = [NSMutableDictionary dictionary];
    disableTextAttrs[NSForegroundColorAttributeName] = TitleColor;
    disableTextAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    [item setTitleTextAttributes:disableTextAttrs forState:UIControlStateDisabled];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationBar setTranslucent:NO];// 导航栏默认不透明
    
    [self.navigationBar showBottomHairline];// 默认显示导航栏底部灰线
    
    [self.navigationBar setBarTintColor:[UIColor whiteColor]]; //导航栏颜色为白色
    
    self.interactivePopGestureRecognizer.delegate = self;
}

/**
 *  重写这个方法目的：能够拦截所有push进来的控制器
 *
 *  @param viewController 即将push进来的控制器
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count > 0) { // 如果push进来的不是第一个控制器
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [button setTitle:@"返回" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        
        [button setImage:[UIImage imageNamed:@"bluearrow"] forState:UIControlStateNormal];
        
        CGRect frame = button.frame;
        frame.size = CGSizeMake(45, 30);
        button.frame = frame;
        // 让按钮内部的所有内容左对齐
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //        button.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        // 隐藏tabbar
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}


-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
     return self.childViewControllers.count > 1;
}

- (void)back
{
    
    [self popViewControllerAnimated:YES];
    
}

@end
