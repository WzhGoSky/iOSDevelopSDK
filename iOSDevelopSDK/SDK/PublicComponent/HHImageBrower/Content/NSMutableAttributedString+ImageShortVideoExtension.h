//
//  NSMutableAttributedString+ImageShortVideoExtension.h
//  iOSDevelop
//
//  Created by Hayder on 2018/10/31.
//

#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (ImageShortVideoExtension)
//添加富文本
+(NSMutableDictionary *)getAttDictWithLineSpacing:(int)lineSpacing font:(UIFont *)font color:(UIColor *)color;
//指定富文本宽度 获取高度
-(CGFloat)getCommentStrHeightWithWidth:(CGFloat)width;
    
@end
