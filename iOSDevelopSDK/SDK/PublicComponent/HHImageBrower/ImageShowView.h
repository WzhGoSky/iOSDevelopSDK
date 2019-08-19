//
//  ImageShowView.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/9/21.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageShowConfig.h"

@interface ImageShowView : UIView

/**
 图片浏览器
 datas: 数据源，数据模型必须实现指定协议方法
 shareBlock: 如果有配置分享事件， 则改通过block 返回资源
 */
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas indexPath:(NSInteger)index inView:(UIView *)inView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock;


/**
 图片浏览器
 datas: 数据源，数据模型必须实现指定协议方法
 type：长按事件 配置alertActions选项
 scrollDirection ： 滚动方向
 view： superView
 indexPath: 指定显示索引
 bottomView: 底部站位view 不需要传nil
 shareBlock: 数据模型
 */
+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas LongPressAlertType:(ShowImageMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index bottomView:(UIView *)bottomView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock;


/**
 图片浏览器
 datas: 数据源(数据模型)
 type：长按事件 配置alertActions选项
 scrollDirection ： 滚动方向
 view： superView
 indexPath: 指定显示索引
 bottomView: 底部站位view 不需要传nil
 shareBlock: 数据模型
 */
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas LongPressAlertType:(ShowImageMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index bottomView:(UIView *)bottomView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock;


/**
 图片浏览器
 datas: 数据源 数据模型必须实现指定协议方法
 type：长按事件 配置alertActions选项
 scrollDirection ： 滚动方向
 view： superView
 indexPath: 指定显示索引
 bottomView: 底部站位view 不需要传nil
 shareBlock: 数据模型 + 索引
 */
+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas LongPressAlertType:(ShowImageMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index bottomView:(UIView *)bottomView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock;

/**
 图片浏览器
 datas: 数据源 数据模型必须实现指定协议方法
 type：长按事件 配置alertActions选项
 scrollDirection ： 滚动方向
 view： superView
 indexPath: 指定显示索引
 bottomView: 底部站位view 不需要传nil
 shareBlock: 数据模型 + 索引
 dismissBlock: 监听消失
 */
+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas LongPressAlertType:(ShowImageMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index bottomView:(UIView *)bottomView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock dismissBlock:(void(^)(void))dismissBlock;

/**
 图片浏览器
 datas: 数据源(数据模型)
 type：长按事件 配置alertActions选项
 scrollDirection ： 滚动方向
 view： superView
 indexPath: 指定显示索引
 bottomView: 底部站位view 不需要传nil
 shareBlock: 数据模型 + 索引
 */
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas LongPressAlertType:(ShowImageMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index bottomView:(UIView *)bottomView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock;

/**
 图片浏览器
 datas: 数据源(数据模型)
 type：长按事件 配置alertActions选项
 scrollDirection ： 滚动方向
 view： superView
 indexPath: 指定显示索引
 bottomView: 底部站位view 不需要传nil
 shareBlock: 数据模型 + 索引
 dismissBlock: 即将消失block
 */
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas LongPressAlertType:(ShowImageMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index bottomView:(UIView *)bottomView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock dismissBlock:(void(^)(void))dismissBlock;

/**
 图片浏览器
 datas: 数据源，数据模型必须实现指定协议方法
 shareBlock: 如果有配置分享事件， 则改通过block 返回资源
 */
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas indexPath:(NSInteger)index shareModelBlock:(void(^)(ImageShowModel *model))shareBlock;

/**
 图片浏览器
 datas: 数据源（数据模型）
 shareBlock: 如果有配置分享事件， 则改通过block 返回资源
 */
+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas indexPath:(NSInteger)index shareModelBlock:(void(^)(ImageShowModel *model))shareBlock;

/**
 图片浏览器
 datas: 数据源  数据模型必须实现指定协议方法
 indexPath： 显示索引
 shareBlock: 如果有配置分享事件， 则改通过block 返回资源
 */
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas indexPath:(NSInteger)index shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock;

/**
 图片浏览器
 datas: 数据源（数据模型）
 indexPath： 显示索引
 shareBlock: 如果有配置分享事件， 则改通过block 返回资源
 */
+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas indexPath:(NSInteger)index shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock;


/**
 图片浏览器
 datas: 数据源（数据模型）
 shareBlock: 如果有配置分享事件， 则改通过block 返回资源
 */
+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas indexPath:(NSInteger)index inView:(UIView *)inView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock;


/**
 图片浏览器
 datas: 数据源，数据模型必须实现指定协议方法
 indexPath： 显示索引
 inView: 父控件
 shareBlock: 如果有配置分享事件， 则改通过block 返回资源
 currentBlock: 当前显示
 */
+(void)showImageBrowsingWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas indexPath:(NSInteger)index inView:(UIView *)inView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock;


/**
 图片浏览器
 datas: 数据源（数据模型）
 indexPath： 显示索引
 inView: 父控件
 shareBlock: 如果有配置分享事件， 则改通过block 返回资源
 currentBlock: 当前显示
 */
+(void)showImageBrowsingWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas indexPath:(NSInteger)index inView:(UIView *)inView shareModelBlock:(void(^)(ImageShowModel *model))shareBlock currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock;

//移除图片浏览器，（注意：这两个方法需要更具你添加的图层来使用对应的移除方式）
+(void)dismiss;
+(void)dismissInSuperView:(UIView *)view;


/**
 获取当前显示的图片浏览器
 返回值可能为空
 */
+(instancetype)getCurrentShowView;
+(instancetype)getCurrentShowWithSuperView:(UIView *)superView;

/**
 编辑方法
 */
-(void)evokeEdit;

/**
 下载
 */
-(void)evokeDownLoad;

/**
 查看原图
 */
-(void)evokeShowOriginal;

/**
 分享
 */
-(ImageShowModel *)evokeShare;

/**
 删除指定数据源图片
 */
-(void)deleteModel:(ImageShowModel *)model;

@end
