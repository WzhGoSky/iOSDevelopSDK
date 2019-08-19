//
//  TZImagePickerHelper.h
//  PublicComponent
//
//  Created by Hayder on 2018/10/11.
//

#import <UIKit/UIKit.h>
@class TZAssetModel,TZImagePickerController,PickerModel;

@interface TZImagePickerHelper : NSObject

+(void)photoPickerHandleModels:(NSMutableArray<TZAssetModel *> *)models photoWidth:(CGFloat)photoWidth complete:(void(^)(NSArray<PickerModel *> *))complete;
+ (void)createCacheFloder;
+ (void)deleteCacheImages;

/**
 处理视屏 合成gif图片
 */
+(void)handlePickerDatas:(NSMutableArray<PickerModel *> *)modelDatas complete:(void(^)(NSMutableArray *datas))complete;


@end
