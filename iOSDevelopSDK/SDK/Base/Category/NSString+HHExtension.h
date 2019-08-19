//
//  NSString+HHExtension.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (HHExtension)

/** 根据宽度获取高度*/
- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW;

/** 根据高度获取宽 */
- (CGFloat)boundingWidthWithHeight:(CGFloat)height font:(UIFont *)font;

/**字符串截取*/
- (NSString *)subStringFrom:(NSString *)startString to:(NSString *)endString;

/**去除前后空格*/
- (NSString *)trim;

/**判断字符串是否全为空格   yes表示全为 no表示不是*/
- (BOOL)isBlankCharacter;

/**是否全是数字*/
- (BOOL)validateNumber;

/**URLEncoded*/
- (NSString *)URLEncodedString;

/**计算当前文件\文件夹的内容大小*/
- (NSInteger)fileSize;

/** 获取字符串的字符长度*/
- (int)convertToByte;

#pragma mark ---------------------正则判断----------------------------
//是否是浮点型
- (BOOL)isPureFloatStr;
//邮箱
- (BOOL)isEmail;
//手机
- (BOOL)isMobile;
//身份证
- (BOOL)isIdentityCard;
//密码强弱
-(BOOL)weakPswd;

@end
