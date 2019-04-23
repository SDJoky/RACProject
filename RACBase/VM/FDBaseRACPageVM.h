//
//  FDBaseRACTableVM.h
//  FloryDay
//
//  Created by joky on 2019/1/28.
//  Copyright © 2019年 ZC HOLDING (HK) LIMITED. All rights reserved.
//

#import "FDBaseScrollVM.h"

/**
 对于刷新传的integer 的page
 */
@interface FDBaseRACPageVM : FDBaseScrollVM

/** request remote data , sub class can override it*/
- (RACSignal *)requestRemoteDataSignalWithPage:(NSUInteger)page;

@end
