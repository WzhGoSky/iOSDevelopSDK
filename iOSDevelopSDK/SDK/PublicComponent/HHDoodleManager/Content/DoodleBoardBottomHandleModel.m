//
//  DoodleBoardColorModel.m
//  AFNetworking
//
//  Created by Hayder on 2019/2/22.
//

#import "DoodleBoardBottomHandleModel.h"

@implementation DoodleBoardBottomHandleModel
    
+(instancetype)modelWithTpye:(DoodleBoardBottomHandleType)type selectIconName:(NSString *)selectIconName normalIconName:(NSString *)normalIconName actionBlock:(void(^)(void))actionBlock{
    
    DoodleBoardBottomHandleModel *model = [[DoodleBoardBottomHandleModel alloc]init];
    model.type = type;
    model.unSelectIconName = normalIconName;
    model.selectIconNAme = selectIconName;
    model.actionBlock = actionBlock;
    return model;
}
@end
