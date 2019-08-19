//
//  HHOSSToolHelper.h
//  HHForAppStore
//
//  Created by Hayder on 2018/9/20.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface HHOSSToolHelper : NSObject
//修改图片
+ (UIImage *)fixOrientationWithImage:(UIImage *)fixImage;
//获取对应的时间
+ (NSString *)currentDateStringWithFormat:(NSString *)formatterStr;
//展示HUD
+ (MBProgressHUD *)HH_showProgressWithDescroption:(NSString *)descripotion withView:(UIView *)containView;
//隐藏HUD
+ (void)HH_hideActivityHUDInContainView:(UIView *)containView;
@end
