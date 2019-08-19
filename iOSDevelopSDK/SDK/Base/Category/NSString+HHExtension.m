//
//  NSString+HHExtension.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import "NSString+HHExtension.h"

@implementation NSString (HHExtension)

/** 1.根据宽度获取高度  */
- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW
{
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    CGSize maxSize = CGSizeMake(maxW, MAXFLOAT);
    
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

/** 2.根据高度获取宽 */
- (CGFloat)boundingWidthWithHeight:(CGFloat)height font:(UIFont *)font
{
    return [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.width;
}

/**3.字符串截取*/
- (NSString *)subStringFrom:(NSString *)startString to:(NSString *)endString
{
    NSRange startRange = [self rangeOfString:startString];
    NSRange endRange = [self rangeOfString:endString];
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    return [self substringWithRange:range];
}

/**4.去除前后空格*/
- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)isBlankCharacter {
    
    if (!self) {
        return true;
    } else {
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        NSString *trimedString = [self stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}

/**6.是否全是数字*/
- (BOOL)validateNumber
{
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < self.length) {
        NSString * string = [self substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

/**7.URLEncoded*/
- (NSString *)URLEncodedString
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              NULL,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

- (NSInteger)fileSize
{
    NSFileManager *mgr = [NSFileManager defaultManager];
    // 判断是否为文件
    BOOL dir = NO;
    BOOL exists = [mgr fileExistsAtPath:self isDirectory:&dir];
    // 文件\文件夹不存在
    if (exists == NO) return 0;
    
    if (dir) { // self是一个文件夹
        // 遍历caches里面的所有内容 --- 直接和间接内容
        NSArray *subpaths = [mgr subpathsAtPath:self];
        NSInteger totalByteSize = 0;
        for (NSString *subpath in subpaths) {
            // 获得全路径
            NSString *fullSubpath = [self stringByAppendingPathComponent:subpath];
            // 判断是否为文件
            BOOL dir = NO;
            [mgr fileExistsAtPath:fullSubpath isDirectory:&dir];
            if (dir == NO) { // 文件
                totalByteSize += [[mgr attributesOfItemAtPath:fullSubpath error:nil][NSFileSize] integerValue];
            }
        }
        return totalByteSize;
    } else { // self是一个文件
        return [[mgr attributesOfItemAtPath:self error:nil][NSFileSize] integerValue];
    }
}

- (int)convertToByte{
    int strlength = 0;
    char* p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    //        return (strlength-3) * 0.5;
    return strlength;
    
}

#pragma mark ---------------------正则判断----------------------------
//是否是浮点型
- (BOOL)isPureFloatStr{
    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

//邮箱
- (BOOL)isEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

//手机
- (BOOL)isMobile
{
    //手机号以13，14， 15，17,18开头，八个 \d 数字字符
    NSString *phoneRegex = @"(^1[3|4|5|7|8][0-9]{9}$)";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:self];
}
//身份证
- (BOOL)isIdentityCard{
    
    BOOL flag;
    if (self.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:self];
}

//密码强弱
-(BOOL)weakPswd{
    NSString *pswdEx =@"^(?=.*\\d.*)(?=.*[a-zA-Z].*).{6,20}$";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pswdEx];
    return [regExPredicate evaluateWithObject:self];
}

@end
