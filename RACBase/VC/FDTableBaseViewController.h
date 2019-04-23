//
//  FDTableBaseViewController.h
//  FloryDay
//
//  Created by joky on 2019/1/29.
//  Copyright © 2019年 ZC HOLDING (HK) LIMITED. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDTableBaseViewController : UIViewController<UITableViewDelegate , UITableViewDataSource>

@property (strong, nonatomic) UITableView * _Nonnull tableListView;

//初始化tableview
- (void)initListViewWithStyle:(UITableViewStyle)style;

//注册cell
- (void)registCell;
// 下拉刷新事件
- (void)tableViewDidTriggerHeaderRefresh;
// 上拉加载事件
- (void)tableViewDidTriggerFooterRefresh;

@end
