//
//  FDBaseScrollVM.m
//  FloryDay
//
//  Created by joky on 2019/1/30.
//  Copyright © 2019年 ZC HOLDING (HK) LIMITED. All rights reserved.
//

#import "FDBaseScrollVM.h"

@implementation FDBaseScrollVM

- (void)initialize {
    [super initialize];
    self.dataSource = [NSArray array];
    self.perPage = 10;
    self.noMoreData = NO;
}
@end
