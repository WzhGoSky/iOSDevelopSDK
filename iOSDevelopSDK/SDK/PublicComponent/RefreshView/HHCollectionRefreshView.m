//
//  CollectionRefreshView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2018/8/28.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHCollectionRefreshView.h"
#import "UIView+HHAdditions.h"
#import "globalDefine.h"
#import "UIView+HUD.h"

@interface HHCollectionRefreshView()

/**是否允许再一次加载*/
@property (nonatomic, assign) BOOL isLoadingDataAgain;

@property (nonatomic, strong) NSMutableArray *refreshImages;

@property (nonatomic, strong) UICollectionViewCell *moveCell;

@end

@implementation HHCollectionRefreshView

- (instancetype)initWithFrame:(CGRect)frame withLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithFrame:frame]) {
        
        [self addCollectionViewWithLayout:layout];
        
        //添加请求无数据view
        self.emptyView = [[HHEmptyView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        self.emptyView.hidden = YES;
        [self addSubview:self.emptyView];
        self.emptyView.delegate = self;
    }
    
    return self;
}

- (void)addCollectionViewWithLayout:(UICollectionViewLayout *)layout
{
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    //设置显示控制代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = RGBA(240, 240, 240, 1);
    //控制垂直方向遇到边框是否反弹
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.collectionView];
}

/**
 为collection添加头部自定义的View
 */
- (void)addHeaderView:(UIView *)customView Size:(CGSize)customViewSize
{
    CGFloat width = customViewSize.width;
    CGFloat height = customViewSize.height;
    CGFloat scale = width/height;
    self.collectionView.contentInset = UIEdgeInsetsMake(scale*SCREEN_WIDTH, 0, 0, 0);
    customView.frame = CGRectMake(0, -SCREEN_WIDTH * scale, SCREEN_WIDTH , SCREEN_WIDTH * scale);
    [self.collectionView addSubview:customView];
}

/**增加拖拽*/
- (void)addDropGestureRecognizer
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.4) {
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
        [self.collectionView addGestureRecognizer:longGesture];
    }else{
        [self toastMessage:@"iOS9.0以上才支持拖拽排序"];
    }
}

- (void)handlelongGesture:(UILongPressGestureRecognizer *)longGesture {
    
    //判断手势状态
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{
            //判断手势落点位置是否在路径上
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longGesture locationInView:self.collectionView]];
            if (indexPath == nil) {
                break;
            }
            //在路径上则开始移动该路径上的cell
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            self.moveCell = cell;
            cell.backgroundColor = kThemeColor;
            if (@available(iOS 9.0, *)) {
                [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            } else {
                // Fallback on earlier versions
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            //移动过程当中随时更新cell位置
            if (@available(iOS 9.0, *)) {
                [self.collectionView updateInteractiveMovementTargetPosition:[longGesture locationInView:self.collectionView]];
            } else {
                // Fallback on earlier versions
            }
            break;
        case UIGestureRecognizerStateEnded:
            self.moveCell.backgroundColor = [UIColor whiteColor];
            //移动结束后关闭cell移动
            if (@available(iOS 9.0, *)) {
                [self.collectionView endInteractiveMovement];
            } else {
                // Fallback on earlier versions
            }
            break;
        default:
            if (@available(iOS 9.0, *)) {
                [self.collectionView cancelInteractiveMovement];
            } else {
                // Fallback on earlier versions
            }
            break;
    }
}
/***
 刷新部分
 */
/**
 添加头部视图刷新
 */
- (void)addHeaderRefresh
{
//    RefreshGifHeader *header = [RefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
//    [header setImages:@[self.refreshImages[0]] forState:RefreshStateIdle];
//    [header setImages:@[self.refreshImages[1]] forState:RefreshStatePulling];
//    [header setImages:self.refreshImages forState:RefreshStateRefreshing];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(loadData)];
    self.collectionView.mj_header = header;
}

/**
 添加尾部视图刷新
 */
- (void)addFooterRefresh
{
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}



- (void)loadData
{
    self.page = 0;
    self.collectionView.mj_footer.hidden = NO;
    [self.collectionView.mj_footer setState:MJRefreshStateIdle];
}

- (void)loadMoreData
{
    self.page++;
}

- (void)endRefreshing
{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
}

- (void)beginRefreshing
{
    [self.collectionView.mj_header beginRefreshing];
}
/**
 处理返回的数据
 */
- (void)handleData:(NSArray *)data isRefresh:(BOOL) isRefresh
{
    self.isLoadingDataAgain = NO;
    
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    if (isRefresh) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:data];
        [self.collectionView reloadData];
        
        if (data.count == 0) {
            
            self.emptyView.hidden = NO;
            self.emptyView.image = [UIImage imageNamed:@"error_no_data"];
            self.emptyView.descriptionText = @"暂无数据";
            self.collectionView.mj_footer.hidden = YES;
        }else
        {
            self.collectionView.mj_footer.hidden = NO;
            self.emptyView.hidden = YES;
        }
        
    }else{
        if (data.count == 0) {
            
            self.collectionView.mj_footer.hidden = YES;
            [self.collectionView.mj_footer setState:MJRefreshStateNoMoreData];
            [self toastMessage:@"没有更多数据了"];
        }else{
            [self.dataSource addObjectsFromArray:data];
            [self.collectionView reloadData];
        }
    }
}

- (void)handleRequestError
{
    self.isLoadingDataAgain = YES;
    
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    
    [self.dataSource removeAllObjects];
    [self.collectionView reloadData];
    
    self.emptyView.hidden = NO;
    self.emptyView.image = [UIImage imageNamed:@"error_no_network"];
    self.emptyView.descriptionText = @"数据请求失败";
    //失败后page--
    if (self.page>0) {
        self.page--;
    }
}

/**处理数据错误*/
- (void)handleErrorWithText:(NSString *)text
{
    self.isLoadingDataAgain = YES;
    
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    
    [self.dataSource removeAllObjects];
    [self.collectionView reloadData];
    
    self.emptyView.hidden = NO;
    self.emptyView.image = [UIImage imageNamed:@"error_no_data"];
    self.emptyView.descriptionText = text?text:@"数据异常";
}
#pragma mark -------------emptyDelegate-------------------
- (void)emptyViewDidClickImage:(HHEmptyView *)emptyView
{
    if (self.isLoadingDataAgain) {
        [self.collectionView.mj_header beginRefreshing];
    }
}

#pragma mark -------------tableViewDelegate-------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {

}

#pragma mark -------------setter, getter-------------------
- (void)setEmptyDescription:(NSString *)emptyDescription
{
    _emptyDescription = emptyDescription;
    
    self.emptyView.descriptionText = emptyDescription;
}


- (NSMutableArray *)refreshImages
{
    if (!_refreshImages) {
        
        _refreshImages = [NSMutableArray array];
        
        for (int i=0; i<12; i++) {
            
            NSString *imageName = [NSString stringWithFormat:@"loading_%d",i];
            UIImage *image = [UIImage imageNamed:imageName];
            [_refreshImages addObject:image];
        }
    }
    
    return _refreshImages;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}


@end
