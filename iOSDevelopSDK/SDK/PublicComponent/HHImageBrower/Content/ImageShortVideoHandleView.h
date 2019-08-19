//
//  ImageShortVideoHandleView.h
//  AFNetworking
//
//  Created by Hayder on 2018/10/31.
//

#import <UIKit/UIKit.h>

#import "ImageShowModel.h"

@interface ImageShortVideoHandleView : UIView

+(instancetype)handleActionViewWithModels:(NSArray<ImageShortVideoHandleModel *> *)models frame:(CGRect)frame;

@end
