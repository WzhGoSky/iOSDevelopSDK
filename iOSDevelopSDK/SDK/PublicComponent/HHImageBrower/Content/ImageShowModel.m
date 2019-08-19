//
//  ImageShowModel.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/22.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "ImageShowModel.h"

@implementation ImageShowModel

-(void)setOriginUrlStr:(NSString *)originUrlStr{
    _originUrlStr = originUrlStr;
    
    _isOriginGif = [originUrlStr containsString:@".gif"];
}

-(void)setImageUrlStr:(NSString *)imageUrlStr{
    _imageUrlStr = imageUrlStr;
    _isGif = [imageUrlStr containsString:@".gif"];
}


@end

@implementation ImageShortVideoHandleModel

+(instancetype)playHandleActionModelWithIcon:(NSString *)icon selectIconName:(NSString *)selectIconName title:(NSString *)title action:(void(^)(UIButton *btn))action{
    ImageShortVideoHandleModel *model = [[ImageShortVideoHandleModel alloc]init];
    model.selectIconName = selectIconName;
    model.iconName = icon;
    model.titleStr = title;
    model.handleBlock = action;
    return model;
}



@end


