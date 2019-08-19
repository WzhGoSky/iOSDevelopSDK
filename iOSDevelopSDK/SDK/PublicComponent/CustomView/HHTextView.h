//
//  TPTextView.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/5/11.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHTextView : UITextView

@property (nonatomic, copy) NSString *placehoder;
@property (nonatomic, strong) UIColor *placehoderColor;

@property (nonatomic, strong) UILabel *placehoderLabel;
@property (nonatomic, strong) UILabel *wordLengthLabel;

@property (nonatomic,assign)  BOOL showWordCounter;

@property (nonatomic,assign)  NSInteger maxWordLength;

@end
