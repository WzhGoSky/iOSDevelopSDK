//
//  ElectronicSignatureTopView.h
//  BaseKit
//
//  Created by Hayder on 2018/10/24.
//

#import <UIKit/UIKit.h>
@class ElectronicSignatureConfig;

@interface ElectronicSignatureTopView : UIView

@property (nonatomic, strong) void(^leftClickBlock)(void);
@property (nonatomic, strong) void(^rightClickBlock)(void);

@property (nonatomic, strong) ElectronicSignatureConfig *config;
@end
