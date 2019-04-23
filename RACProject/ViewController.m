//
//  ViewController.m
//  RACProject
//
//  Created by joky on 2019/4/16.
//  Copyright © 2019年 joky. All rights reserved.
//

#import "ViewController.h"
#import "RACVM.h"
@interface ViewController ()

@property(nonatomic,strong) UITextField *nameTxtF;

@property(nonatomic,strong) UITextField *pswTxtF;

@property(nonatomic,strong) RACVM *viewModel;

@property(nonatomic,strong) UIButton *loginBtn;

@property(nonatomic,strong) UILabel *consoleLbl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self bindViewModel];
//    [self testOptional];
//    [self functionTakeLast];
    
//    [self concat];
//    [self merge];
//    [self useWithMap];
//    [self useWithFilter];
//    [self useWithThrottle];
}

- (void)bindViewModel
{
    self.viewModel = [[RACVM alloc] init];
    @weakify(self);
    //switchToLatest获取最新的信号
//    distinctUntilChanged相同值不会多次被订阅
    RACDisposable *disposable = [[self.viewModel.requestCommand.executionSignals.switchToLatest distinctUntilChanged] subscribeNext:^(RACModel *  _Nullable x) {
        @strongify(self);
        self.nameTxtF.text = x.nameStr;
    }];
    
//    [disposable dispose];
    
    [self.viewModel.requestCommand.executionSignals.flatten subscribeNext:^(RACModel * _Nullable x) {
        NSLog(@"executionSignals--%@",x.nameStr);
    }];
    
    [self.nameTxtF.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"***rac_textSignal方式文本改变：***%@",self.nameTxtF.text);
    }];
    
    [RACObserve(self.nameTxtF, text) subscribeNext:^(id  _Nullable x) {
        NSLog(@"***RACObserve方式文本改变：***%@",self.nameTxtF.text);
    }];
    
    RAC(self.loginBtn, enabled) = [RACSignal combineLatest:@[self.nameTxtF.rac_textSignal,self.pswTxtF.rac_textSignal] reduce:^id (NSString *name,NSString *psw){
        @strongify(self);
        if (name.length == 0 || psw.length == 0) {
            [self.loginBtn setTitle:@"不可点" forState:UIControlStateNormal];
            return @0;
        }else
        {
            [self.loginBtn setTitle:@"可点" forState:UIControlStateNormal];
            return @1;
        }
    }];
    
}

- (void)testOptional
{
//    NSArray * array = @[@"大吉大利",@"今晚吃鸡",@66666,@99999];
    NSDictionary * dict = @{@"key1":@"value1",
                            @"key2":@"value2",
                            @"key3":@"value3"
                            };
//    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
    
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"key:%@--value:%@",x[0],x[1]);
        
//        RACTupleUnpack(NSString *key,id value) = x;
//        NSLog(@"key -- %@ value -- %@",key,value);
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"监听通知--弹出键盘");
    }];
    
    //    定时器
//   RACDisposable *disable = [[RACSignal interval:2 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
//        NSLog(@"定时器----di da di da");
//    }];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [disable dispose];
//    });
}

-(void)functionTakeLast {
    
    RACSubject * subject = [RACSubject subject];
    //取的是最后几个值
    [[subject takeLast:2] subscribeNext:^(id x) {
        
        NSLog(@"takeLast----%@",x);
        self.consoleLbl.text = [NSString stringWithFormat:@"takeLast---%@",x];
    }];
//    [[subject take:1] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"take---%@",x);
//    }];
//
//    [[subject distinctUntilChanged] subscribeNext:^(id x) {
//
//        NSLog(@"distinctUntilChanged---%@",x);
//
//    }];
    
    [subject sendNext:@"第一个"];
    [subject sendNext:@"第二个"];
    [subject sendNext:@"第三个"];
    [subject sendNext:@"第三个"];
    [subject sendCompleted];
    
}


/*
 两个信号串联:想让上部分先进行网络请求但是过滤掉数据，然后进行下部分的，拿到下部分数据
 */
-(void)concat{
    
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"上部分数据"];
            [subscriber sendCompleted];
        });
        return nil;
    }];
    
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"下部分数据"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //**-注意-**：concat，第一个信号必须要调用sendCompleted
    RACSignal * concatSignal = [signalA concat:signalB];
    [concatSignal subscribeNext:^(id x) {
        NSLog(@"concat---%@",x);
    }];
    
}


/**
 两个信号串联:多个信号合并成一个信号，任何一个信号有新值就会调用 ,任何一个信号请求完成都会被订阅到
 */
-(void)merge{
    
    RACSubject * signalA = [RACSubject subject];
    
    RACSubject * signalB = [RACSubject subject];
    //组合信号
    RACSignal * mergeSignal = [signalA merge:signalB];
    [mergeSignal subscribeNext:^(id x) {
        self.consoleLbl.text = [NSString stringWithFormat:@"mergeSignal---%@",x];
        NSLog(@"mergeSignal--%@",x);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [signalA sendNext:@"信号1"];
    });
    [signalB sendNext:@"信号2"];
}


/**
 改造信号
 */
- (void)useWithMap
{
    //创建一个信号
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"唱歌"];
        [subscriber sendCompleted];
        return nil;
        
    }];
    
    RAC(self, nameTxtF.text) = [signalA map:^id(NSString *value) {
        if ([value isEqualToString:@"唱歌"]) {
            return @"跳舞";
        }
        return @"";
        
    }];
}


/**
 过滤
 */
- (void)useWithFilter
{
    RACSignal *singal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@(1)];
        [subscriber sendNext:@(8)];
        [subscriber sendNext:@(21)];
        [subscriber sendNext:@(18)];
        [subscriber sendNext:@(10)];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    
    [[singal filter:^BOOL(NSNumber *value) {
        //return为yes可以通过
        return value.integerValue >= 15;
        
    }] subscribeNext:^(id x) {
        NSLog(@"filter-----%@",x);
        
    }];
}


/**
 节流 控制通道  貌似有问题
 */
- (void)useWithThrottle
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"用户1"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"用户2"];
            [subscriber sendNext:@"用户3"];
            [subscriber sendNext:@"用户4"];
            [subscriber sendNext:@"用户2"];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"用户5"];
            [subscriber sendNext:@"用户6"];
        });
        return nil;
    }];
    
    [[signal throttle:1] subscribeNext:^(id x) {
        NSLog(@"%@通过了",x);
    }];
    
}

-(void)configUI
{
    self.nameTxtF = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, 200, 30)];
    self.nameTxtF.borderStyle = UITextBorderStyleRoundedRect;
    self.nameTxtF.placeholder = @"your name ";
    self.nameTxtF.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.nameTxtF];
    
    self.pswTxtF = [[UITextField alloc] initWithFrame:CGRectMake(20, 200, 200, 30)];
    self.pswTxtF.borderStyle = UITextBorderStyleRoundedRect;
    self.pswTxtF.placeholder = @"your password ";
    self.pswTxtF.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.pswTxtF];
    
    self.consoleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 260, 150, 100)];
    self.consoleLbl.font = [UIFont systemFontOfSize:13];
    self.consoleLbl.numberOfLines = 0;
    self.consoleLbl.textColor = [UIColor redColor];
    [self.view addSubview:self.consoleLbl];
    
    self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginBtn.frame = CGRectMake(20, self.view.frame.size.height - 100, self.view.frame.size.width - 40, 40);
    [self.loginBtn setTitle:@"login" forState:UIControlStateNormal];
    [self.loginBtn setBackgroundColor:[[UIColor purpleColor] colorWithAlphaComponent:0.5]];
    __block int input = 1;
    @weakify(self);
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self.viewModel.requestCommand execute:[NSString stringWithFormat:@"%d",input ++]];
    }];
    [self.view addSubview:self.loginBtn];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
