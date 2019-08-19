//
//  ElectronicSignatureConfig.h
//  BaseKit
//
//  Created by Hayder on 2018/10/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ElectronicSignatureConfig : NSObject

@property (nonatomic, strong) NSString *titleStr;

@property (nonatomic, strong) NSString *topLeftTitle;

@property (nonatomic, strong) NSString *topRightTitle;

@property (nonatomic, assign) CGFloat topHandleFont;

@property (nonatomic, assign) CGFloat topTitleFont;

/**
 主题线颜色
 */
@property (nonatomic, strong) NSString *lineTintColor;
/**
 顶部操作 主题色
 */
@property (nonatomic, strong) NSString *topHandeColor;

+(instancetype)defaultConfig;

@end

