//
//  FDBaseRACViewModel.h
//  FloryDay
//
//  Created by joky on 2019/1/25.
//  Copyright © 2019年 ZC HOLDING (HK) LIMITED. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <MJRefresh/MJRefresh.h>

@interface FDBaseRACVM : NSObject
@property (nonatomic, readwrite, assign) BOOL requestDataOnViewDidLoad;

/// 会在init之后自动执行的方法 重写在这里
- (void)initialize;
@end
