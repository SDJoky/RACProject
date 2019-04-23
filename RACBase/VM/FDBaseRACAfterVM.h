//
//  FDBaseRACAfterVM.h
//  FloryDay
//
//  Created by joky on 2019/1/30.
//  Copyright © 2019年 ZC HOLDING (HK) LIMITED. All rights reserved.
//

#import "FDBaseScrollVM.h"

NS_ASSUME_NONNULL_BEGIN
/**
 对于刷新传的string 的after
 */
@interface FDBaseRACAfterVM : FDBaseScrollVM

/** request remote data , sub class can override it*/
- (RACSignal *)requestRemoteDataSignalWithAfter:(NSString *)after;

@end

NS_ASSUME_NONNULL_END
