//
//  FDBaseScrollVM.h
//  FloryDay
//
//  Created by joky on 2019/1/30.
//  Copyright © 2019年 ZC HOLDING (HK) LIMITED. All rights reserved.
//

#import "FDBaseRACVM.h"

NS_ASSUME_NONNULL_BEGIN
//滚动视图基类ViewModel
@interface FDBaseScrollVM : FDBaseRACVM

///这里不能用NSMutableArray，因为NSMutableArray不支持KVO，不能被RACObserve
@property (nonatomic, readwrite, strong) NSArray *dataSource;

/** 下来刷新 defalut is NO*/
@property (nonatomic, readwrite, assign) BOOL shouldPullDownToRefresh;
/** 上拉加载 defalut is NO*/
@property (nonatomic, readwrite, assign) BOOL shouldPullUpToLoadMore;
/// 每一页的数据 defalut is 15
@property (nonatomic, readwrite, assign) NSUInteger perPage;

/// didSelectRowAtIndexPath
@property (nonatomic, readwrite, strong) RACCommand *didSelectCommand;

/// 请求服务器数据的命令
@property (nonatomic,readwrite, strong) RACCommand *requestRemoteDataCommand;

/// 是否以page形式请求接口
@property(nonatomic,assign) BOOL isPageRequest;

/// 当前页 defalut is 1 传的是page
@property (nonatomic, readwrite, assign) NSUInteger page;

/// 当前页 defalut is "" 分页传的是字符串
@property (nonatomic, readwrite, copy) NSString *after;

/// 是否已是最后数据
@property (nonatomic, readwrite, assign) BOOL noMoreData;

@end

NS_ASSUME_NONNULL_END
