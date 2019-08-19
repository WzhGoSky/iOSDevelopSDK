//
//  DoodleBoardClipAreaLayer.h
//  AFNetworking
//
//  Created by Hayder on 2019/4/12.
//

#import <QuartzCore/QuartzCore.h>
#import "DoodleBoardClipConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoodleBoardClipAreaLayer : CAShapeLayer
@property(assign, nonatomic) NSInteger cropAreaLeft;
@property(assign, nonatomic) NSInteger cropAreaTop;
@property(assign, nonatomic) NSInteger cropAreaRight;
@property(assign, nonatomic) NSInteger cropAreaBottom;
@property (nonatomic, strong) DoodleBoardClipConfigModel *configModel;

- (void)setCropAreaLeft:(NSInteger)cropAreaLeft CropAreaTop:(NSInteger)cropAreaTop CropAreaRight:(NSInteger)cropAreaRight CropAreaBottom:(NSInteger)cropAreaBottom configModel:(DoodleBoardClipConfigModel *)configModel;

@end

NS_ASSUME_NONNULL_END
