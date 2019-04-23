//
//  RACVM.m
//  RACProject
//
//  Created by joky on 2019/4/16.
//  Copyright © 2019年 joky. All rights reserved.
//

#import "RACVM.h"
@interface RACVM()

@property(nonatomic,strong,readwrite) RACCommand *requestCommand;

@end

@implementation RACVM

-(instancetype)init
{
    if (self = [super init]) {
        
        self.requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            NSLog(@"--发起请求----%@",input);
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                
                //请求 解析数据的过程
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    RACModel *model = [[RACModel alloc] init];
                    model.nameStr = input;
                    self.model = model;
                    [subscriber sendNext:self.model];
                    [subscriber sendCompleted];
                });
                return [RACDisposable disposableWithBlock:^{
                    NSLog(@"disposable");
                }];;
            }];
        }];
    }
    return self;
}

- (void)combindRequest
{
    
}

@end
