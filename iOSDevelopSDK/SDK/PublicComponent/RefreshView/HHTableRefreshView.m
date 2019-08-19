//
//  TableViewRefreshView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2017/9/28.
//  Copyright © 2017年 Hayder. All rights reserved.
//

#import "HHTableRefreshView.h"
#import "UIView+HHAdditions.h"
#import "globalDefine.h"
#import "UIView+HUD.h"

#define tableRefreshImageNamed(imageName) [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[TableRefreshView class]] pathForResource:imageName ofType:@"png" inDirectory:@"Refresh.bundle"]]
@interface HHTableRefreshView()

@property (nonatomic, strong) NSMutableArray *refreshImages;

/**是否允许再一次加载*/
@property (nonatomic, assign) BOOL isLoadingDataAgain;

@end

@implementation HHTableRefreshView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.tableView];
        
        //添加请求无数据view
        self.emptyView = [[HHEmptyView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        self.emptyView.hidden = YES;
        [self addSubview:self.emptyView];
        self.emptyView.delegate = self;
    }
    
    return self;
}


/***
 刷新部分
 */
/**
 添加头部视图刷新
 */
- (void)addHeaderRefresh
{
//    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
//    [header setImages:@[self.refreshImages[0]] forState:MJRefreshStateIdle];
//    [header setImages:@[self.refreshImages[1]] forState:MJRefreshStatePulling];
//    [header setImages:self.refreshImages forState:MJRefreshStateRefreshing];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(loadData)];
    self.tableView.mj_header = header;
}

/**
 添加尾部视图刷新
 */
- (void)addFooterRefresh
{
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

- (void)loadData
{
    self.page = 0;
    self.tableView.mj_footer.hidden = NO;
    [self.tableView.mj_footer setState:MJRefreshStateIdle];
}

- (void)loadMoreData
{
    self.page++;
}

- (void)beginRefreshing
{
    [self.tableView.mj_header beginRefreshing];
}

- (void)endRefreshing
{
    [self.tableView.mj_footer endRefreshing];
    [self.tableView.mj_header endRefreshing];
}

/**
 处理返回的数据
 */
- (void)handleData:(NSArray *)data isRefresh:(BOOL) isRefresh
{
    self.isLoadingDataAgain = NO;
    
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    if (isRefresh) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:data];
        [self.tableView reloadData];
        
        if (data.count == 0) {
            
            self.emptyView.hidden = NO;
            self.emptyView.image = [UIImage imageNamed:@"error_no_data"];
            self.emptyView.descriptionText = self.emptyDescription?self.emptyDescription:@"暂无数据";
            self.tableView.mj_footer.hidden = YES;
        }else
        {
            self.tableView.mj_footer.hidden = NO;
            self.emptyView.hidden = YES;
        }
        
    }else
    {
        if (data.count == 0) {
            
            self.tableView.mj_footer.hidden = YES;
            [self.tableView.mj_footer setState:MJRefreshStateNoMoreData];
            [self toastMessage:@"没有更多数据了"];
        }else
        {
            [self.dataSource addObjectsFromArray:data];
            [self.tableView reloadData];
        }
    }
}

- (void)handleRequestError
{
    self.isLoadingDataAgain = YES;
    
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
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
    
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
    self.emptyView.hidden = NO;
    self.emptyView.image = [UIImage imageNamed:@"error_no_data"];
    self.emptyView.descriptionText = text?text:@"数据异常";
}
#pragma mark -------------emptyDelegate-------------------
- (void)emptyViewDidClickImage:(HHEmptyView *)emptyView
{
    if (self.isLoadingDataAgain) {
        [self.tableView.mj_header beginRefreshing];
    }
}

#pragma mark -------------tableViewDelegate-------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
    }
    
    return cell;
}

#pragma mark -------------setter, getter-------------------
- (void)setEmptyDescription:(NSString *)emptyDescription
{
    _emptyDescription = emptyDescription;
    
    self.emptyView.descriptionText = emptyDescription;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _tableView;
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
