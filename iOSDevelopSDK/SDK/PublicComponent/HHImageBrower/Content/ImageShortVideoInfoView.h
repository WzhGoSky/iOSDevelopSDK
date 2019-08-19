//
//  ImageShortVideoInfoView.h
//  AFNetworking
//
//  Created by Hayder on 2018/10/31.
//   短视频信息界面

#import <UIKit/UIKit.h>
@class ImageShowModel;

@protocol ImageShortVideoInfoViewDelegate <NSObject>
-(void)ImageShortVideoInfoViewDidClickUserheader:(ImageShowModel *)mode;
@end

@interface ImageShortVideoInfoView : UIView

@property (nonatomic, weak) id<ImageShortVideoInfoViewDelegate> delegate;

@property (nonatomic, strong) ImageShowModel *model;
@end
