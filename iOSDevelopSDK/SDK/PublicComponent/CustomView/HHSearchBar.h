//
//  HHSearchBar.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/3/28.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HHSearchBar;
@protocol HHNSearchDelegate<NSObject>

@optional
/**搜索栏结束输入后回调 带延迟(推荐)*/
- (void)searchBar:(HHSearchBar *)searchBar didEndEditing:(NSString *)text;

/**搜索栏结束输入后回调 不带延迟*/
- (void)searchBar:(HHSearchBar *)searchBar didEndEditingNoDealy:(NSString *)text;

@end

@interface HHSearchBar : UITextField

@property (nonatomic, assign) id<HHNSearchDelegate> nDelegate;

+ (instancetype)searchBar;

@end
