//
//  HHTitleScrollController.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/4/26.
//  Copyright © 2019 iOSDevelopSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HHTitleScrollController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *titleView;

@property (nonatomic, strong) UIScrollView *contentView;
//上面标题
@property (nonatomic, strong) NSArray *titleSource;

@property (nonatomic, strong) UIView *line;

/**上一个点击的按钮*/
@property (nonatomic, strong) UIButton *lastBtn;

- (void)clickButton:(UIButton *)button;

@end

NS_ASSUME_NONNULL_END
