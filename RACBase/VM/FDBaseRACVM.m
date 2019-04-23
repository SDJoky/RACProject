//
//  FDBaseRACViewModel.m
//  FloryDay
//
//  Created by joky on 2019/1/25.
//  Copyright © 2019年 ZC HOLDING (HK) LIMITED. All rights reserved.
//

#import "FDBaseRACVM.h"
@implementation FDBaseRACVM
/// when `BaseViewModel` created and call `initWithParams` method , so we can ` initialize `
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    FDBaseRACVM *viewModel = [super allocWithZone:zone];
    
    @weakify(viewModel)
    [[viewModel rac_signalForSelector:@selector(init)] subscribeNext:^(id x) {
        @strongify(viewModel)
        [viewModel initialize];
    }];
    return viewModel;
}

- (instancetype)init {
    if (self = [super init]) {
        self.requestDataOnViewDidLoad = YES;
    }
    return self;
}

/// sub class can override
- (void)initialize {
    
}


@end
