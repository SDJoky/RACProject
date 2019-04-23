//
//  FDCollectionViewController.h
//  FloryDay
//
//  Created by joky on 2019/1/30.
//  Copyright © 2019年 ZC HOLDING (HK) LIMITED. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDCollectionBaseController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView * _Nonnull collectionView;

//初始化collectionView 包含注册cell方法
- (void)initCollectionViewWithLayout:(UICollectionViewLayout *_Nullable)layout;

//注册cell
- (void)registCell;
// 下拉刷新事件
- (void)collectionViewDidTriggerHeaderRefresh;
// 上拉加载事件
- (void)collectionViewDidTriggerFooterRefresh;
@end
