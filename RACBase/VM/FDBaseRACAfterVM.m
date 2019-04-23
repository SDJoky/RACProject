//
//  FDBaseRACAfterVM.m
//  FloryDay
//
//  Created by joky on 2019/1/30.
//  Copyright © 2019年 ZC HOLDING (HK) LIMITED. All rights reserved.
//

#import "FDBaseRACAfterVM.h"

@implementation FDBaseRACAfterVM

- (void)initialize
{
    [super initialize];
    self.after = @"";
    self.isPageRequest = NO;
    @weakify(self)
    self.requestRemoteDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSString *  _Nullable after) {
        @strongify(self)
        return [self requestRemoteDataSignalWithAfter:after];
    }];
}

- (RACSignal *)requestRemoteDataSignalWithAfter:(NSString *)after
{
    return [RACSignal empty];
}
@end
