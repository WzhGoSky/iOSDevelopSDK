//
//  NSMutableAttributedString+ImageShortVideoExtension.m
//  iOSDevelop
//
//  Created by Hayder on 2018/10/31.
//

#import "NSMutableAttributedString+ImageShortVideoExtension.h"

@implementation NSMutableAttributedString (ImageShortVideoExtension)
//添加富文本
+(NSMutableDictionary *)getAttDictWithLineSpacing:(int)lineSpacing font:(UIFont *)font color:(UIColor *)color{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSMutableDictionary *transmitDic = [@{
                                          NSFontAttributeName: font,
                                          NSForegroundColorAttributeName:color,
                                          NSParagraphStyleAttributeName:paragraphStyle,
                                          } mutableCopy];
    return transmitDic;
}

//指定富文本宽度 获取高度
-(CGFloat)getCommentStrHeightWithWidth:(CGFloat)width{
    if (self.string.length) {
        return  [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height;//附带与底部间距
    }else{
        return 0;
    }
}
@end
