//
//  HHCamera.m
//  HHCamera
//
//  Created by Hayder on 2018/10/4.
//  Copyright © 2018年 Hayder. All rights reserved.
//

#import "HHNormalCamera.h"
#import "HHAVKitConfig.h"
#import "HHCameraPhotoCell.h"
#import "HHCameraHelper.h"

@interface HHNormalCamera ()<UICollectionViewDelegate,UICollectionViewDataSource,HHCameraPhotoCellDelegate>

@property (nonatomic, strong) UICollectionView *photosView;
//拍照的照片
@property (nonatomic, strong) NSMutableArray *photos;

//已选张数
@property (nonatomic, strong) UILabel *selectedNum;
//最大的选择张数
@property (nonatomic, strong) UILabel *maxSelectedNum;
//已选照片的张数
@property (nonatomic, assign) NSInteger selectedPhotoNum;

@end

@implementation HHNormalCamera

- (instancetype)initWithFrame:(CGRect)frame Option:(HHAVKitOption *)option
{
    if (self = [super initWithFrame:frame Option:option]) {
        //创建缓存文件夹
        [HHCameraHelper createCacheFloder];
        
        self.isUseLocalCacheProlicy = YES;
    }
    return self;
}

- (BOOL)isLegalOption
{
    return (self.option.type == SessionTypePhoto)?YES:NO;
}

- (void)addSubViews
{
    self.photos = [NSMutableArray array];
    
    CGFloat selfHeight = self.frame.size.height;
    CGFloat selfWidth = self.frame.size.width;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 20;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat itemHeight = 93;
    layout.itemSize = CGSizeMake(itemHeight-20, itemHeight);
    self.photosView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, selfHeight - (83 + 30), selfWidth, 83 + 30) collectionViewLayout:layout];
    [self.photosView registerClass:[HHCameraPhotoCell class] forCellWithReuseIdentifier:@"HHCameraPhotoCell"];
    self.photosView.backgroundColor = [UIColor blackColor];
    self.photosView.delegate = self;
    self.photosView.dataSource = self;
    [self addSubview:self.photosView];
    
    UILabel *maxSelectedNum = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.photosView.frame) - 20, selfWidth/2, 20)];
    [self addSubview:maxSelectedNum];
    maxSelectedNum.backgroundColor = [UIColor blackColor];
    maxSelectedNum.textColor = [UIColor whiteColor];
    
    maxSelectedNum.text = [NSString stringWithFormat:@"最大选择张数:%ld张",(long)self.option.maxPhotoCount];
    self.maxSelectedNum = maxSelectedNum;
    
    UILabel *selectedNum = [[UILabel alloc] initWithFrame:CGRectMake(selfWidth/2, CGRectGetMinY(self.photosView.frame) - 20, selfWidth/2, 20)];
    [self addSubview:selectedNum];
    selectedNum.backgroundColor = [UIColor blackColor];
    selectedNum.textColor = [UIColor whiteColor];
    
    selectedNum.text = [NSString stringWithFormat:@"%@0%@",@"已选",@"张"];
    selectedNum.textAlignment = NSTextAlignmentRight;
    self.selectedNum = selectedNum;
    
    //拍照按钮
    self.takePhotoBtn = [[UIButton alloc] init];
    [self.takePhotoBtn setBackgroundImage:[UIImage imageNamed:@"record_normal"] forState:UIControlStateNormal];
    self.takePhotoBtn.frame = CGRectMake((selfWidth - 60)/2, selfHeight - self.photosView.frame.size.height-80, 60, 60);
    [self.takePhotoBtn addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.takePhotoBtn];
    
    //取消按钮
    self.cancelBtn = [[UIButton alloc] init];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(onCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn.frame = CGRectMake(CGRectGetMinX(self.takePhotoBtn.frame)-60-30, self.takePhotoBtn.frame.origin.y, 60, 60);
    [self addSubview:self.cancelBtn];
    
    //确定按钮
    self.sureBtn = [[UIButton alloc] init];
    [self.sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.sureBtn addTarget:self action:@selector(onResultSelected:) forControlEvents:UIControlEventTouchUpInside];
    self.sureBtn.frame = CGRectMake(CGRectGetMaxX(self.takePhotoBtn.frame)+30, self.takePhotoBtn.frame.origin.y, 60, 60);
    [self addSubview:self.sureBtn];
    
    if (self.option.maxPhotoCount == 1) {
        self.selectedNum.hidden = YES;
        self.maxSelectedNum.hidden = YES;
        self.photosView.hidden = YES;
        self.sureBtn.hidden = YES;
        self.takePhotoBtn.frame = CGRectMake((selfWidth - 60)/2, selfHeight - 160, 60, 60);
        self.cancelBtn.frame = CGRectMake(CGRectGetMaxX(self.takePhotoBtn.frame)+20, self.takePhotoBtn.frame.origin.y, 60, 60);
    }
}

#pragma mark ---------------------HHCameraPhotoCellDelegate-----------------------------------------
- (void)cameraPhotoCell:(HHCameraPhoto *)model didClickSelectedOrUnselected:(UIButton *)sender
{
    NSInteger maxCount = self.option.maxPhotoCount;
    if (self.selectedPhotoNum == maxCount) { //等于最大数 不让选择 可以取消
        if (!model.photoSelected) {
            return;
        }
        model.photoSelected = NO;
        sender.selected = NO;
        self.selectedPhotoNum --;
        
        self.selectedNum.text = [NSString stringWithFormat:@"已选:%ld张",(long)self.selectedPhotoNum];
    }else
    {
        if (model.photoSelected) { //选中情况下 会反选
            self.selectedPhotoNum --;
        }else
        {
            self.selectedPhotoNum ++;
        }
        
        sender.selected = !sender.selected;
        model.photoSelected = sender.selected;
        self.selectedNum.text = [NSString stringWithFormat:@"已选:%ld张",(long)self.selectedPhotoNum];
    }
}

#pragma mark ---------------------event response-----------------------------------------
//确定按钮
- (void)onResultSelected:(UIButton *)sender
{
    if (self.photos.count == 0) {
        return;
    }
    
    NSMutableArray *imagaes = [NSMutableArray array];
    for (HHCameraPhoto *model in self.photos) {
        if (model.photoSelected) {
            [imagaes addObject:model.photo];
        }
    }
    
    if (imagaes.count > 0) {
        if ([self.delegate respondsToSelector:@selector(normalCamera:didFinishedTakingPhoto:)]) {
            [self.delegate normalCamera:self didFinishedTakingPhoto:imagaes];
        }
    }
    
    [self hideSelf];
}
//取消
- (void)onCancelBtn:(UIButton *)sender
{
    [self hideSelf];
}

//拍照
- (void)shutterCamera
{
    self.takePhotoBtn.enabled = NO;
    [self removeDelayTimer];
    [self addTimerWithTime:0.7];
    
    NSInteger maxCount = self.option.maxPhotoCount;
    [self takePhotoCompletion:^(UIImage *image) {
        if (maxCount <= 1) {
            if ([self.delegate respondsToSelector:@selector(normalCamera:didFinishedTakingPhoto:)]) {
                [self.delegate normalCamera:self didFinishedTakingPhoto:@[image]];
            }
        }else
        {
            //统计当前选中张数
            NSInteger i = 0;
            for (HHCameraPhoto *model in self.photos) {
                if (model.photoSelected) {
                    i++;
                }
            }
            //拍照结束
            HHCameraPhoto *model = [[HHCameraPhoto alloc] init];
            model.photo = [self takePhotoEndWithImage:image];
            //保存图片到本地路径 防止内存爆炸
            if (self.isUseLocalCacheProlicy) {
                [HHCameraHelper saveImageToFile:model.photo];
            }            
            [self.photos addObject:model];
            if (i==maxCount) {
                model.photoSelected = NO;
                self.selectedNum.text = [NSString stringWithFormat:@"已选:%ld张",(long)maxCount];
                self.selectedPhotoNum = maxCount;
            }else
            {
                self.selectedNum.text =  [NSString stringWithFormat:@"已选:%ld张", i+1];
                self.selectedPhotoNum = i+1;
            }
            
            //刷新视图
            [self.photosView reloadData];
            [self.photosView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.photos.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
    }];
}

- (void)clickDelay
{
    self.takePhotoBtn.enabled = YES;
    [self removeDelayTimer];
}

- (UIImage *)takePhotoEndWithImage:(UIImage *)originalImage
{
    return originalImage;
}

#pragma mark ---------------------collectionViewCell-----------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HHCameraPhoto *model = self.photos[indexPath.item];
    HHCameraPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HHCameraPhotoCell" forIndexPath:indexPath];
    cell.model = model;
    cell.delegate = self;
    return cell;
}


@end
