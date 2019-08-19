//
//  DrawingBoard.m
//  PublicComponent
//
//  Created by Hayder on 2018/10/19.
//

#import "DrawingBoard.h"
#import "DrawingModel.h"
#import "globalDefine.h"
#import "DoodleBoardView.h"
#import "DoodleBoradViewTopHandleView.h"

@interface DrawingBoard()<UICollectionViewDelegate,UICollectionViewDataSource,DoodleBoradViewTopHandleViewDelegate,DoodleBoardViewCellDelegate>

@property (nonatomic, strong) UICollectionView *mainView;
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) void(^editCompleteBlock)(NSArray<UIImage *> *);

@property (nonatomic, strong) NSMutableArray<UIImage *> *imgs;

@property (nonatomic, assign) DoodleBoardHandleType type;

@property (nonatomic, strong) DoodleBoradViewTopHandleView *topHandleView;

@end

@implementation DrawingBoard

+(void)showASetOfImgsDrawing:(NSArray<UIImage *> *)imgArray type:(DoodleBoardHandleType)type inView:(UIView *)superView complete:(void(^)(NSArray<UIImage *> *editArray))complete{
    DrawingBoard *view = [[DrawingBoard alloc]initWithFrame:[UIScreen mainScreen].bounds];
    view.type = type;
    view.imgs = imgArray;
    view.editCompleteBlock =complete;
    [superView addSubview:view];
    [superView bringSubviewToFront:view];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.mainView];
        [self addSubview:self.topHandleView];
    }
    return self;
}

-(void)setImgs:(NSMutableArray<UIImage *> *)imgs{
    _imgs = imgs;
    NSMutableArray *temp = [NSMutableArray array];
    for (UIImage *img in imgs) {
        DrawingModel *model = [[DrawingModel alloc]init];
        model.img = img;
        [temp addObject:model];
    }
    self.modelArray = temp;
    [self.mainView reloadData];
}

#pragma DoodleBoardViewCellDelegate
-(void)DoodleBoardViewCellDidChangeState:(BOOL)isNormal{
    self.topHandleView.hidden = !isNormal;
    self.mainView.scrollEnabled = isNormal;
}

#pragma DoodleBoradViewTopHandleViewDelegate
/**
 取消事件
 */
-(void)doodleBoradViewTopHandleViewDidCacnel:(UIButton *)btn{
    [self removeFromSuperview];
}

/**
 完成事件
 */
-(void)doodleBoradViewTopHandleViewDidFinfish:(UIButton *)btn{
    
    NSMutableArray *temp = [NSMutableArray array];
    for (DrawingModel *model in self.modelArray) {
        [temp addObject:model.img];
    }
    !self.editCompleteBlock?:self.editCompleteBlock(temp);
    [self removeFromSuperview];
}

#pragma mark ----collectionViewDelegate-----
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.modelArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DoodleBoardViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DoodleBoardViewCell class]) forIndexPath:indexPath];
    cell.boardType = DoodleBoardViewNormal;
    cell.isHybrid = YES;
    cell.type = self.type;
    cell.delegate = self;
    DrawingModel *model = self.modelArray[indexPath.row];
    cell.model = model;
    return cell;
}


-(UICollectionView *)mainView{
    if (!_mainView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = [UIScreen mainScreen].bounds.size;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        _mainView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
        _mainView.backgroundColor = [UIColor blackColor];
        _mainView.delegate = self;
        _mainView.dataSource = self;
        _mainView.pagingEnabled = YES;
        _mainView.bounces = YES;
        _mainView.showsVerticalScrollIndicator = NO;
        _mainView.showsHorizontalScrollIndicator = NO;
        [_mainView registerClass:[DoodleBoardViewCell class] forCellWithReuseIdentifier:NSStringFromClass([DoodleBoardViewCell class])];
    }
    return _mainView;
}

-(DoodleBoradViewTopHandleView *)topHandleView{
    if (!_topHandleView) {
        _topHandleView = [[DoodleBoradViewTopHandleView alloc]initWithFrame:CGRectMake(0, 44, self.frame.size.width, 44)];
        _topHandleView.delegate = self;
    }
    return _topHandleView;
}


@end
