//
//  RACVM.h
//  RACProject
//
//  Created by joky on 2019/4/16.
//  Copyright © 2019年 joky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

#import "RACModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RACVM : NSObject

@property(nonatomic,strong,readonly) RACCommand *requestCommand;

@property(nonatomic,strong) RACModel *model;

@end

NS_ASSUME_NONNULL_END
