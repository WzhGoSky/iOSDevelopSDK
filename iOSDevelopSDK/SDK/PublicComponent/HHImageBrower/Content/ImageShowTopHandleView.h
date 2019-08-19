//
//  ImageShowTopHandleView.h
//  test
//
//  Created by Hayder on 2018/9/27.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageShowConfig.h"

@protocol ImageShowTopHandleViewDelegate <NSObject>
-(void)ImageShowTopHandleViewDidBack;
-(void)ImageShowTopHandleViewDidShareClick;
-(void)ImageShowTopHandleViewDidEditClick;
@end

@interface ImageShowTopHandleView : UIView

@property (nonatomic, assign) ShowImageMangerType type;

@property (nonatomic, assign) BOOL isVideo;

@property (nonatomic, assign) NSInteger totalCount;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL needBackBtn;

-(instancetype)initWithFrame:(CGRect)frame delegate:(id<ImageShowTopHandleViewDelegate>)delegate needBack:(BOOL)needBack;

@end
