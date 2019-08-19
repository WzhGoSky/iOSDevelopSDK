//
//  HHVideoCameraHelper.h
//  AFNetworking
//
//  Created by Hayder on 2018/11/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^generateGifImageBlock)(BOOL isSuccessed,NSString *imageURL);
@interface HHVideoCameraHelper : NSObject

+ (instancetype)getHelper;
/**
 生成gif图片
 */
- (void)generateImagesInAsset:(AVAsset *)asset Completion:(generateGifImageBlock) completion;
/**
 通过videoURL生成gif
 */
- (void)generateImagesWithVideoPath:(NSString *)videoPath Completion:(generateGifImageBlock)completion;

+ (BOOL)deleteFileWithName:(NSString *)gifName;

@end

