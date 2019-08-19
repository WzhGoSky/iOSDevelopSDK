//
//  QXRootViewController.m
//  JYQX
//
//  Created by Hayder on 2018/8/20.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHRootViewController.h"
#import "HHNavigationController.h"
#import "UIImage+HHExtension.h"
#import "globalDefine.h"

#define NormalTitleColor [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1]
#define SelectedTitleColor kThemeColor

@interface HHRootViewController ()

@end

@implementation HHRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //取消tabbr半透明
    self.tabBar.backgroundColor = [UIColor whiteColor];
//    // 添加子控制器
//    [self addChildVc:[[QXHomeController alloc] init] title:@"首页" image:@"shouye" selectedImage:@"shouye"];
//    [self addChildVc:[[QXListController alloc] init] title:@"交友" image:@"jiaoyou" selectedImage:@"jiaoyou"];
//    [self addChildVc:[[QXMessageController alloc] init] title:@"悄悄话" image:@"qiaoqiaohua" selectedImage:@"qiaoqiaohua-selected"];
//    [self addChildVc:[[QXMineViewController alloc] init] title:@"我的" image:@"wode" selectedImage:@"wode"];
}




/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图片
 *  @param selectedImage 选中的图片
 */
- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    // 设置标题
    childVc.title = title;
    
    // 设置图标
    childVc.tabBarItem.image = [UIImage imageNamed:image];
    
    // 设置tabBarItem的普通文字颜色
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:10];
    textAttrs[NSForegroundColorAttributeName] = NormalTitleColor;
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    // 设置tabBarItem的选中文字颜色
    NSMutableDictionary *selectedTextAttrs = [NSMutableDictionary dictionary];
    selectedTextAttrs[NSForegroundColorAttributeName] = SelectedTitleColor;
    [childVc.tabBarItem setTitleTextAttributes:selectedTextAttrs forState:UIControlStateSelected];
    
    // 设置选中的图标
    UIImage *selected = nil;
    selected = [[[UIImage imageNamed:selectedImage] imageWithTintColor:kThemeColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = selected;
    
    // 添加为tabbar控制器的子控制器
    HHNavigationController *nav = [[HHNavigationController alloc] initWithRootViewController:childVc];
    [self addChildViewController:nav];
}

@end
