//
//  ShortVideoView.m
//  iOSDevelop
//
//  Created by Hayder on 2018/10/31.
//

#import "ShortVideoView.h"
//#import "ImageShortVideoHandleView.h"
//#import "ImageShortVideoInfoView.h"

@interface ShortVideoView()<ImageShowDeitalViewDelegate,ShoreVideoHandleDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

/**
 短视频 事件
 */
@property (nonatomic, assign) ShowShortVideoMangerType shortVideoType;

@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) UICollectionView *mainView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

@property (nonatomic, strong) ImageShowModel *currentModel;

@property (nonatomic, assign) BOOL showHandle;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) void(^currentInfoBlock)(NSInteger index, ImageShowModel *model);

@property (nonatomic, weak) id<ShortVideoViewDelegate> delegate;

@end

@implementation ShortVideoView

+(void)showShortVideoWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas toIndexPath:(NSInteger)index currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock delegate:(id<ShortVideoViewDelegate>)delegate{
    [self showShortVideoWithModelDatas:datas handleType:(ShowShortVideoMangerTypeLike | ShowShortVideoMangerTypeComment | ShowShortVideoMangerTypeShare | ShowShortVideoMangerTypeDownLoad) scrollDirection:UICollectionViewScrollDirectionVertical inView:[UIApplication sharedApplication].keyWindow toIndexPath:index currentBlock:currentBlock delegate:delegate];
}

+(void)showShortVideoWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas toIndexPath:(NSInteger)index currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock likeBlock:(void(^)(NSInteger index, ImageShowModel *model))likeBlock delegate:(id<ShortVideoViewDelegate>)delegate{
    
    [self showShortVideoWithDatas:datas handleType:(ShowShortVideoMangerTypeLike | ShowShortVideoMangerTypeComment | ShowShortVideoMangerTypeShare | ShowShortVideoMangerTypeDownLoad)  scrollDirection:UICollectionViewScrollDirectionVertical inView:[UIApplication sharedApplication].keyWindow toIndexPath:index currentBlock:currentBlock delegate:delegate];
}

+(void)showShortVideoWithDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas handleType:(ShowShortVideoMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock delegate:(id<ShortVideoViewDelegate>)delegate{
    ShortVideoView *mainView = [[ShortVideoView alloc]initWithFrame:[UIScreen mainScreen].bounds withScrollDirection:scrollDirection type:type];
    mainView.currentInfoBlock = currentBlock;
    mainView.currentIndex = index;
    mainView.datas = datas;
    mainView.delegate = delegate;
    [mainView.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]  atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [view addSubview:mainView];
    [view bringSubviewToFront:mainView];
}

+(void)showShortVideoWithModelDatas:(NSMutableArray<ImageShowModel *> *)datas handleType:(ShowShortVideoMangerType)type scrollDirection:(UICollectionViewScrollDirection)scrollDirection inView:(UIView *)view toIndexPath:(NSInteger)index currentBlock:(void(^)(NSInteger index, ImageShowModel *model))currentBlock delegate:(id<ShortVideoViewDelegate>)delegate{
    ShortVideoView *mainView = [[ShortVideoView alloc]initWithFrame:[UIScreen mainScreen].bounds withScrollDirection:scrollDirection type:type];
    mainView.currentInfoBlock = currentBlock;
    mainView.currentIndex = index;
    mainView.datas = datas;
    [mainView.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]  atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    mainView.delegate = delegate;
    [view addSubview:mainView];
    [view bringSubviewToFront:mainView];
}


-(instancetype)initWithFrame:(CGRect)frame withScrollDirection:(UICollectionViewScrollDirection)scrollDirection type:(ShowShortVideoMangerType) type{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.shortVideoType = type;
        
        self.scrollDirection = scrollDirection;
        self.backgroundColor = [UIColor blackColor];
        
        [self addSubview:self.mainView];
    }
    return self;
}

#pragma ShortVideoViewCellDelegate
-(void)ShortVideoViewCellDidLike{
    if ([self.delegate respondsToSelector:@selector(ShortVideoLike:index:)]) {
        [self.delegate ShortVideoLike:self.currentModel index:self.currentIndex];
    }
}

-(void)ShortVideoViewCellDidComment{
    if ([self.delegate respondsToSelector:@selector(ShortVideoComment:index:)]) {
        [self.delegate ShortVideoComment:self.currentModel index:self.currentIndex];
    }
}

-(void)ShortVideoViewCellDidShare{
    if ([self.delegate respondsToSelector:@selector(ShortVideoShare:index:)]) {
        [self.delegate ShortVideoShare:self.currentModel index:self.currentIndex];
    }
}

-(void)ShortVideoViewCellDidDownLoad{
    if ([self.delegate respondsToSelector:@selector(ShortVideoDownLoad:index:)]) {
        [self.delegate ShortVideoDownLoad:self.currentModel index:self.currentIndex];
    }
}

-(void)ShortVideoViewDidClickUserHeader{
    if ([self.delegate respondsToSelector:@selector(ShortVideoClickUserHeader:index:)]) {
        [self.delegate ShortVideoClickUserHeader:self.currentModel index:self.currentIndex];
    }
}

-(void)setDatas:(NSMutableArray<id<ImageShowViewDelegate>> *)datas{
    NSMutableArray *temp = [NSMutableArray array];
    for (id<ImageShowViewDelegate> subData in datas) {
        ImageShowModel *model = nil;
        
        if (![subData isKindOfClass:[ImageShowModel class]]) {
            model = [[ImageShowModel alloc]init];
            if ([subData respondsToSelector:@selector(ImageShowViewImageUrl)]) {
                model.imageUrlStr = [subData ImageShowViewImageUrl];
            }
            if ([subData respondsToSelector:@selector(ImageShowViewOriginalImageUrl)]) {
                model.originUrlStr = [subData ImageShowViewOriginalImageUrl];
                model.isOrigin =  model.originUrlStr.length;
            }
            if ([subData respondsToSelector:@selector(ImageShowViewVideoUrl)]) {
                model.viodeUrlStr = [subData ImageShowViewVideoUrl];
                model.isVideo = model.viodeUrlStr.length;
            }
            if ([subData respondsToSelector:@selector(ImageShowViewImageWidth)]) {
                model.imgWidth = [subData ImageShowViewImageWidth];
            }
            if ([subData respondsToSelector:@selector(ImageShowViewImageHeight)]) {
                model.imgHeight = [subData ImageShowViewImageHeight];
            }
            
            if ([subData respondsToSelector:@selector(ImageShowViewImageDes)]) {
                if (!model.isVideo) {
                    model.iconDes = [subData ImageShowViewImageDes];
                }
            }
            
            if ([subData respondsToSelector:@selector(ImageShowViewImage)]) {
                model.img = [subData ImageShowViewImage];
            }
            
            if ([subData respondsToSelector:@selector(ImageShortVideoNickName)]) {
                model.nickName = [subData ImageShortVideoNickName];
            }
            
            if ([subData respondsToSelector:@selector(ImageShortVideoUserHeaderIcon)]) {
                model.userHeader = [subData ImageShortVideoUserHeaderIcon];
            }
            
            if ([subData respondsToSelector:@selector(ImageShortVideoTitle)]) {
                model.shortVideoTitle = [subData ImageShortVideoTitle];
            }
            
            if ([subData respondsToSelector:@selector(ImageShortVideoSubTitle)]) {
                model.shortVideoSubTItle = [subData ImageShortVideoSubTitle];
            }
            
        }else{
            model = (ImageShowModel *)subData;
        }
        
        [temp addObject:model];
    }
    
    _datas = temp;
    __block ImageShowModel *firstModel = temp[self.currentIndex];
    self.currentModel = firstModel;
    
    !self.currentInfoBlock?:self.currentInfoBlock(self.currentIndex,self.currentModel);
    
    [self.mainView reloadData];
}

#pragma ImageShowDeitalViewDelegate
/**
 返回
 */
-(void)ImageShowDeitalViewDidClickBack{
    [self removeFromSuperview];
}
/**
 长按
 */
-(void)ImageShowDeitalViewDidAlertWithModel:(ImageShowModel *)model{
    
}

/**
 隐藏
 */
-(void)ImageShowDeitalViewDidDismiss{
    //    //获取当前显示的cell
    ShortVideoViewCell *cellItem = [self.mainView visibleCells].lastObject;

    self.showHandle = !self.showHandle;
    
    [cellItem ImageShowDeitalViewDidDismiss:self.showHandle];
}



#pragma UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ShortVideoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ShortVideoViewCell class]) forIndexPath:indexPath];
    ImageShowModel *model = self.datas[indexPath.row];
    cell.shortVideoType = self.shortVideoType;
    cell.model = model;
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    ShortVideoViewCell *tempCell = (ShortVideoViewCell *)cell;
      [tempCell ImageShowDeitalViewDidDismiss:NO];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    ShortVideoViewCell *tempCell = (ShortVideoViewCell *)cell;
    [tempCell pause];
    [tempCell ImageShowDeitalViewDidDismiss:NO];
}

#pragma mark - UIScrollDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 停止类型1、停止类型2
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        // 停止类型3
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [self scrollViewDidEndScroll];
        }
    }
}

#pragma mark - scrollView 停止滚动监测

- (void)scrollViewDidEndScroll {
    
    NSInteger current = 0;
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        current = self.mainView.contentOffset.x / self.mainView.frame.size.width;
    }else{
        current = self.mainView.contentOffset.y / self.mainView.frame.size.height;
    }
    
    self.currentIndex = current;
    
    self.currentModel = self.datas[current];

    !self.currentInfoBlock?:self.currentInfoBlock(self.currentIndex,self.currentModel);
    
}

#pragma lazy

-(UICollectionViewFlowLayout *)flowLayout{
    if (!_flowLayout) {
        //1.创建layout布局对象
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //2.设置每个item的大小（cell）
        layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        [layout setScrollDirection:self.scrollDirection];
        _flowLayout = layout;
    }
    return _flowLayout;
}

-(UICollectionView *)mainView{
    if (!_mainView) {
        _mainView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _mainView.pagingEnabled = YES;
        _mainView.delegate = self;
        _mainView.dataSource = self;
        _mainView.backgroundColor = [UIColor clearColor];
        _mainView.showsHorizontalScrollIndicator = NO;
        _mainView.showsVerticalScrollIndicator = NO;
        [_mainView registerClass:[ShortVideoViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ShortVideoViewCell class])];
    }
    return _mainView;
}

@end
