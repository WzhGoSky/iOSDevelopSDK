//
//  DrawingHelper.h
//  PublicComponent
//
//  Created by Hayder on 2018/10/19.
//

#import <UIKit/UIKit.h>

@interface DrawingHelper : NSObject
/**
 从本地取出图片
 
 @param nameStr 图片名
 @return 图片
 */
+(UIImage *)readImageWithName:(NSString *)nameStr;
/**
 存图片到本地
 
 @param image 图片
 @return 图片名
 */
+(NSString *)saveImage:(UIImage *)image andName:(NSString *)name;



/**
 通过遍历像素点实现马赛克效果,level越大,马赛克颗粒越大,若level为0则默认为图片1/20
 */
+ (UIImage *)getMosaicImageWith:(UIImage *)image level:(NSInteger)level;

/**
 通过滤镜来实现马赛克效果(只能处理.png格式的图片)
 */
+ (UIImage *)getFilterMosaicImageWith:(UIImage *)image;

+ (UIImage *)drawImgWithImg:(UIImage *)img rect:(CGRect)rect;


@end
