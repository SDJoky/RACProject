//
//  FDTableBaseViewController.m
//  FloryDay
//
//  Created by joky on 2019/1/29.
//  Copyright © 2019年 ZC HOLDING (HK) LIMITED. All rights reserved.
//

#import "FDTableBaseViewController.h"
#import "FDBaseScrollVM.h"

@interface FDTableBaseViewController()

@property (nonatomic, readwrite, strong) FDBaseScrollVM *racVM;

@property(nonatomic,assign) UITableViewStyle style;

@end

@implementation FDTableBaseViewController
@dynamic racVM;

- (void)dealloc {
    // set nil
    _tableListView.dataSource = nil;
    _tableListView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        if ([self.racVM requestDataOnViewDidLoad]) {
            @weakify(self)
            [[self rac_signalForSelector:@selector(viewDidLoad)] subscribeNext:^(id x) {
                @strongify(self)
                [self _checkNetWork];
            }];
        }
    }
    return self;
}

- (void)configViewModel {
    self.racVM = [FDBaseScrollVM new];
}

- (void)registCell {
    
}

- (void)_checkNetWork {
    if (!self.racVM.shouldPullDownToRefresh) {
        [self tableViewDidTriggerHeaderRefresh];
    }else
    {
        [self.tableListView.mj_header beginRefreshing];
    }
    
}

/// override
- (void)bindViewModel {
    @weakify(self)
    [[[RACObserve(self, racVM.dataSource) distinctUntilChanged] deliverOnMainThread] subscribeNext:^(id x) {
         @strongify(self)
         // 刷新数据
         [self.tableListView reloadData];
     }];
    
    [[[RACObserve(self, racVM.noMoreData) distinctUntilChanged] deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self)
        if ([x boolValue]) {
            [self.tableListView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
}

- (void)initListViewWithStyle:(UITableViewStyle)style {
    self.style = style;
    [self registCell];
    /// 添加加载和刷新控件
    if (self.racVM.shouldPullDownToRefresh) {
        /// 下拉刷新
        @weakify(self);
        self.tableListView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            /// 加载下拉刷新的数据
            @strongify(self);
            [self tableViewDidTriggerHeaderRefresh];
        }];
    }
    if (self.racVM.shouldPullUpToLoadMore) {
        /// 上拉加载
        @weakify(self);
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            /// 加载上拉刷新的数据
            @strongify(self);
            [self tableViewDidTriggerFooterRefresh];
        }];
        footer.triggerAutomaticallyRefreshPercent = -20;
        self.tableListView.mj_footer = footer;
    }
    [self.view addSubview:self.tableListView];
}

#pragma mark - sub class can override it
/// 下拉事件
- (void)tableViewDidTriggerHeaderRefresh {
    @weakify(self)
    if (self.racVM.isPageRequest) {
        [[[self.racVM.requestRemoteDataCommand  execute:@1] deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self)
            self.racVM.page = 1;
        } error:^(NSError *error) {
            @strongify(self)
            [self tableViewDidFinishTriggerHeader:YES];
        } completed:^{
            @strongify(self)
            [self tableViewDidFinishTriggerHeader:YES];
        }];
    } else {
        [[[self.racVM.requestRemoteDataCommand
           execute:@""] deliverOnMainThread] subscribeNext:^(id x) {
        } error:^(NSError *error) {
            @strongify(self)
            [self tableViewDidFinishTriggerHeader:YES];
        } completed:^{
            @strongify(self)
            [self tableViewDidFinishTriggerHeader:YES];
        }];
    }
    
}

/// 上拉事件
- (void)tableViewDidTriggerFooterRefresh {
    @weakify(self);
    if (self.racVM.isPageRequest) {
        [[[self.racVM.requestRemoteDataCommand
           execute:@(self.racVM.page + 1)]
          deliverOnMainThread]
         subscribeNext:^(id x) {
             @strongify(self)
             self.racVM.page += 1;
         } error:^(NSError *error) {
             @strongify(self);
             [self tableViewDidFinishTriggerHeader:NO];
         } completed:^{
             @strongify(self)
             [self tableViewDidFinishTriggerHeader:NO];
         }];
    } else {
        [[[self.racVM.requestRemoteDataCommand execute:self.racVM.after]
          deliverOnMainThread]
         subscribeNext:^(id x) {
         } error:^(NSError *error) {
             @strongify(self);
             [self tableViewDidFinishTriggerHeader:NO];
         } completed:^{
             @strongify(self)
             [self tableViewDidFinishTriggerHeader:NO];
         }];
    }
}

//数据请求完之后header footer状态
- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (isHeader) {
            [self.tableListView.mj_header endRefreshing];
        } else {
            [self.tableListView.mj_footer endRefreshing];
        }
        
        // 最后一页
        if (self.racVM.noMoreData) {
            if(self.racVM.dataSource.count == 0) {
                [self.tableListView.mj_header setHidden:YES];
            } else {
                [self.tableListView.mj_header setHidden:NO];
                [self.tableListView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    });
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellReuseIdentifier = NSStringFromClass([self class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellReuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.racVM.didSelectCommand execute:indexPath];
}

- (UITableView *)tableListView {
    if(!_tableListView) {
        _tableListView = [[UITableView alloc] initWithFrame:CGRectZero
                                                      style:self.style];
        _tableListView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableListView.separatorColor =[UIColor groupTableViewBackgroundColor];
        _tableListView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.1)];
        _tableListView.dataSource = self;
        _tableListView.delegate = self;
        
        _tableListView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.1)];
        _tableListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableListView.estimatedRowHeight = 10;
        _tableListView.estimatedSectionFooterHeight = 0;
        _tableListView.estimatedSectionHeaderHeight = 0;
        if (@available(iOS 11.0, *)) {
            _tableListView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableListView;
}

@end
