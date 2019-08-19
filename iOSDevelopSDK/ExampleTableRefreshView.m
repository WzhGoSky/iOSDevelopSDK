//
//  ExampleTableRefreshView.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/14.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import "ExampleTableRefreshView.h"

@implementation ExampleTableRefreshView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addHeaderRefresh];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        [self beginRefreshing];
    }
    return self;
}

- (void)loadData
{
    [super loadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
        [self handleData:@[] isRefresh:YES];
    });
}

- (void)loadMoreData
{
    [super loadMoreData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    return cell;
}


@end
