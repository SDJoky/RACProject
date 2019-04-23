//
//  FDCollectionViewController.m
//  FloryDay
//
//  Created by joky on 2019/1/30.
//  Copyright © 2019年 ZC HOLDING (HK) LIMITED. All rights reserved.
//

#import "FDCollectionBaseController.h"
#import "FDBaseScrollVM.h"

@interface FDCollectionBaseController()

@property (nonatomic, readwrite, strong) FDBaseScrollVM *racVM;

@end

@implementation FDCollectionBaseController
@dynamic racVM;

- (void)dealloc {
    // set nil
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configViewModel {
    self.racVM = [FDBaseScrollVM new];
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

- (void)_checkNetWork {
    //检测网络变化
    if (!self.racVM.shouldPullDownToRefresh) {
        [self collectionViewDidTriggerHeaderRefresh];
    }else
    {
        [self.collectionView.mj_header beginRefreshing];
    }
}

/// override
- (void)bindViewModel {
    @weakify(self)
    [[[RACObserve(self.racVM, dataSource) distinctUntilChanged] deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self)
        // 刷新数据
        [self.collectionView reloadData];
    }];
}

- (void)initCollectionViewWithLayout:(UICollectionViewLayout *)layout {
    [self registCell];
    [self.collectionView setCollectionViewLayout:layout];
    /// 添加加载和刷新控件
    if (self.racVM.shouldPullDownToRefresh) {
        /// 下拉刷新
        @weakify(self);
        self.collectionView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            /// 加载下拉刷新的数据
            @strongify(self);
            [self collectionViewDidTriggerHeaderRefresh];
        }];
    }
    if (self.racVM.shouldPullUpToLoadMore) {
        /// 上拉加载
        @weakify(self);
        
        MJRefreshAutoFooter *footer= [MJRefreshAutoFooter footerWithRefreshingBlock:^{
            /// 加载上拉刷新的数据
            @strongify(self);
            [self collectionViewDidTriggerFooterRefresh];
        }];
        footer.triggerAutomaticallyRefreshPercent = -20;
        self.collectionView.mj_footer = footer;
    }
    [self.view addSubview:self.collectionView];
}

#pragma mark - sub class can override it
/// 下拉事件
- (void)collectionViewDidTriggerHeaderRefresh {
    @weakify(self)
    if (self.racVM.isPageRequest) {
        [[[self.racVM.requestRemoteDataCommand
           execute:@1] deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self)
            self.racVM.page = 1;
        } error:^(NSError *error) {
            @strongify(self)
            [self collectionViewDidFinishTriggerHeader:YES];
        } completed:^{
            @strongify(self)
            [self collectionViewDidFinishTriggerHeader:YES];
        }];
    } else {
        [[[self.racVM.requestRemoteDataCommand
           execute:@""] deliverOnMainThread] subscribeNext:^(id x) {
        } error:^(NSError *error) {
            @strongify(self)
            [self collectionViewDidFinishTriggerHeader:YES];
        } completed:^{
            @strongify(self)
            [self collectionViewDidFinishTriggerHeader:YES];
        }];
    }
}

/// 上拉事件
- (void)collectionViewDidTriggerFooterRefresh {
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
             [self collectionViewDidFinishTriggerHeader:NO];
         } completed:^{
             @strongify(self)
             [self collectionViewDidFinishTriggerHeader:NO];
         }];
    } else {
        [[[self.racVM.requestRemoteDataCommand execute:self.racVM.after] deliverOnMainThread]
         subscribeNext:^(id x) {
             NSLog(@"requestCommand-after-%@",self.racVM.after);
         } error:^(NSError *error) {
             @strongify(self);
             [self collectionViewDidFinishTriggerHeader:NO];
         } completed:^{
             @strongify(self)
             [self collectionViewDidFinishTriggerHeader:NO];
         }];
    }
}

//数据请求完之后header footer状态
- (void)collectionViewDidFinishTriggerHeader:(BOOL)isHeader {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (isHeader) {
            [self.collectionView.mj_header endRefreshing];
        } else {
            [self.collectionView.mj_footer endRefreshing];
        }
        
        // 最后一页
        if (self.racVM.noMoreData) {
            if(self.racVM.dataSource.count == 0) {
                [self.collectionView.mj_header setHidden:YES];
            } else {
                [self.collectionView.mj_header setHidden:NO];
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    });
    
}
#pragma mark -- collectionview delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.racVM.didSelectCommand execute:indexPath];
}

- (void)registCell{
    [self.collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:@"UICollectionViewCell"];
}

- (UICollectionView *)collectionView {
    if(!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:[UICollectionViewLayout new]];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets=NO;
        }
       
    }
    return _collectionView;
}
@end
