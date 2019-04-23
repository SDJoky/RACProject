//
//  FDBaseRACTableVM.m
//  FloryDay
//
//  Created by joky on 2019/1/28.
//  Copyright © 2019年 ZC HOLDING (HK) LIMITED. All rights reserved.
//

#import "FDBaseRACPageVM.h"

@implementation FDBaseRACPageVM

- (void)initialize {
    [super initialize];
    self.page = 1;
    self.isPageRequest = YES;
    @weakify(self)
    self.requestRemoteDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *  _Nullable page) {
        @strongify(self)
        return [self requestRemoteDataSignalWithPage:page.unsignedIntegerValue];
    }];
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSUInteger)page
{
    return [RACSignal empty];
}

@end
