//
//  EmptyView.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2017/4/24.
//  Copyright © 2017年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HHEmptyView;
@protocol HHEmptyViewDelegate <NSObject>

@optional
- (void)emptyViewDidClickImage:(HHEmptyView *)emptyView;

@end

@interface HHEmptyView : UIView

@property (nonatomic, copy) NSString *descriptionText;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, weak) id<HHEmptyViewDelegate> delegate;

@end
