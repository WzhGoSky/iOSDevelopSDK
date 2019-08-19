//
//  TZPickerImageConfig.h
//  AFNetworking
//
//  Created by Hayder on 2018/11/6.
//

#import <Foundation/Foundation.h>

@interface TZPickerImageConfig : NSObject

@property (nonatomic, assign) BOOL needGetModels;

/**
 是否需要显示原图按钮
 */
@property (nonatomic, assign) BOOL needOriginal;

@property (nonatomic, assign) BOOL canEdit;

+(instancetype)shareInstance;
@end
