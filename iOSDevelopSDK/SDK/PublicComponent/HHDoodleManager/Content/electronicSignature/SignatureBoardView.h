//
//  SignatureBoardView.h
//  test
//
//  Created by Hayder on 2018/10/24.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignatureBoardView : UIImageView

- (instancetype)initWithFrame:(CGRect)frame img:(UIImage *)img;
/**
 恢复初始状态
 */
- (void)clean;

/**
 是否编辑过
 */
-(BOOL)isEdit;
@end
