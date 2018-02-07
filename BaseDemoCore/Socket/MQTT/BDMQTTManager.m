//
//  BDMQTTManager.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/16.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDMQTTManager.h"
#import "BDMQTTService.h"
#import "BDPackageService.h"

static float scheduledTimeInterval =0.5;
static NSThread *mqttManagerThread;
static NSString *BDMQTTManagerThreadName=@"BDMQTTManagerThreadName";

@interface BDMQTTManager ()
{
    BOOL _isAddedToRunLoop; //是否已将定时器加入runloop中
}
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation BDMQTTManager

+(instancetype)sharedManager
{
    static BDMQTTManager *manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[BDMQTTManager alloc]init];
    });
    return manager;
}
-(id)init
{
    if (self=[super init])
    {
        [self addNotificationObservers];
    }
    return self;
}

-(void)addNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
-(void)appDidBecomeActive:(NSNotification *)noti
{
    if (!_timer.isValid)
    {
        _isAddedToRunLoop=NO;
        [self addTimerToRunLoop];
    }
}
-(void)resumeConnectedTimer
{
    [self removeTimerFromRunLoop];
    [self addTimerToRunLoop];
    //开启包下载服务
    [BDPackageService sharedService];
}

//添加定时器到runloop
-(void)addTimerToRunLoop
{
    if (!_isAddedToRunLoop)
    {
        //开启线程
        [[self class] startMQTTManagerThreadIfNeeded];
        [[self class] performSelector:@selector(scheduleTimer:) onThread:mqttManagerThread withObject:self waitUntilDone:YES];
        _isAddedToRunLoop=YES;
    }
}
//移除定时器
-(void)removeTimerFromRunLoop
{
    if (_isAddedToRunLoop)
    {
        //需要保证线程
        [[self class] performSelector:@selector(unScheduleTimer:) onThread:mqttManagerThread withObject:self waitUntilDone:YES];
        _isAddedToRunLoop=YES;
    }
}

#pragma mark-管理定时器
+(void)scheduleTimer:(BDMQTTManager *)manager
{
    NSRunLoop *runLoop=[NSRunLoop currentRunLoop];
    [runLoop addTimer:manager.timer forMode:NSRunLoopCommonModes];
}
+(void)unScheduleTimer:(BDMQTTManager *)manager
{
    [manager stopTimer];
}
-(void)stopTimer
{
    _isAddedToRunLoop=NO;
    if (_timer)
    {
        [_timer invalidate];
        _timer=nil;
    }
}


+(void)startMQTTManagerThreadIfNeeded
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        mqttManagerThread=[[NSThread alloc]initWithTarget:self selector:@selector(mqttManagerThread) object:nil];
        [mqttManagerThread start];
    });
}
+(void)mqttManagerThread
{
    @autoreleasepool{
        
        [[NSThread currentThread] setName:BDMQTTManagerThreadName];
        NSRunLoop *runloop=[NSRunLoop currentRunLoop];
        //此处添加port只是为了不让runloop退出 并没有实际的发送消息
        [runloop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
        [runloop run];
    }
}

-(NSTimer *)timer
{
    //没有Timer并且没有添加到runloop
    if (!_timer&&!_isAddedToRunLoop)
    {
        _timer=[NSTimer timerWithTimeInterval:scheduledTimeInterval target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    }
    return _timer;
}
-(void)timer:(NSTimer *)timer
{
    @autoreleasepool{
        
        BDMQTTService *service=[BDMQTTService sharedService];
        switch (service.connectStatus) {
            case BDMQTTConnectStatus_Connecting:
                NSLog(@"MQTT连接中......");
                break;
            case BDMQTTConnectStatus_Connected:
                [service timerTrigger];
                break;
            case BDMQTTConnectStatus_Close:
                [service connectMQTT]; //重新连接
                break;
            default:
                break;
        }
        
    }
}














@end
