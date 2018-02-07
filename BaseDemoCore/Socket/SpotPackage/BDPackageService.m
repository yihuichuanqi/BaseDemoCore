//
//  BDPackageService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/18.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDPackageService.h"
#import "BDHandlePackage.h"
#import "BDSpotFlowService.h"
#import "BDSpotService.h"

#import "NSDictionary+BD.h"
#import "NSNotificationCenter+MainThread.h"

#define kPackage_HandleFailTimeInterval 300 //下载解压缩失败后 重试相隔时间

static NSMutableDictionary *executingQueue; //处理中的zip 包括下载解压入库

@interface BDPackageService ()

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSMutableArray *packages;
@property (nonatomic,strong) BDHandlePackageDao *packageDao;
@end


@implementation BDPackageService

-(BDHandlePackageDao *)packageDao
{
    if (!_packageDao)
    {
        _packageDao=[[BDHandlePackageDao alloc]init];
        [_packageDao createTable:YES];
    }
    return _packageDao;
}
+(instancetype)sharedService
{
    static BDPackageService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDPackageService alloc]init];
    });
    return service;
}
-(id)init
{
    if (self=[super init])
    {
        executingQueue=[NSMutableDictionary dictionary];
        _packages=[NSMutableArray array];
        [self addTimerAndNotificationObservers];
    }
    return self;
}

-(void)addTimerAndNotificationObservers
{
    //定时器
    _timer=[NSTimer timerWithTimeInterval:5 target:self selector:@selector(startDownload) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeTimer) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseTimer) name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)startDownload
{
    @autoreleasepool{
        
        //网络不通 则不处理
        
        //存在执行中 则不处理
        if (executingQueue.count)
        {
            return;
        }
        //从数据库获取 执行语句
        if (self.packages.count==0)
        {
            NSArray *array=[self.packageDao getAllPackagesWithEachBlock:nil];
            if (array&&array.count)
            {
                [self.packages addObjectsFromArray:array];
            }
        }
        if (self.packages.count>0)
        {
            BDHandlePackage *firstPackage=self.packages.firstObject;
            if (![self canDownloadPackage:firstPackage])
            {
                //距离上一次小于间隔则不重试
                return;
            }
            [[BDSpotFlowService sharedService] handleDownloadWithPackage:firstPackage];
            [executingQueue bd_safeSetObject:firstPackage forKey:firstPackage.url];
        }
        else
        {
            //暂停定时器
            [self pauseTimer];
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:kCompletedDownloadZipQueueNotification object:nil];
        }
    }
}
//下载成功 则删除此路径
-(void)endDownloadWith:(BDHandlePackage *)package
{
    if (self.packages.count)
    {
        [self.packages removeObject:self.packages.firstObject];
    }
    [self.packageDao deletePackageWithUrl:package.url];
    //移除内存
    [executingQueue bd_safeRemoveObjectForKey:package.url];
    //继续检车队列
    [self startDownload];
}
-(void)handlePackage:(BDHandlePackage *)package
{
    @autoreleasepool{
        
        if (package.isMulPackages)
        {
            // 多包
            NSArray *packageComponents=[package.packages componentsSeparatedByString:@","];
            NSMutableArray *packages=[NSMutableArray array];
            NSInteger orderBy=0;
            for (NSString *component in packageComponents)
            {
                //兼容此情况 0.zip
                if (!component.length)
                {
                    continue;
                }
                NSString *url=[NSString stringWithFormat:@"%@%@?t=%@",package.urlRoot,component,@(package.updateTime)];
                NSMutableDictionary *bodyDict=[NSMutableDictionary dictionaryWithDictionary:package.bodyDict];
                [bodyDict bd_safeRemoveObjectForKey:@"packages"];
                [bodyDict bd_safeSetObject:url forKey:@"url"];
                [bodyDict bd_safeSetObject:@(orderBy) forKey:@"packageOrder"];
                [packages addObject:[BDHandlePackage package:bodyDict msgId:package.msgId]];
                orderBy++;
                
            }
            //入库
            [self storePackage:packages orgPackage:package];
        }
        else
        {
            package.packageOrderBy=0;
            [self storePackage:@[package] orgPackage:package];
        }
    }
}

-(void)replacePackageInfoWithPackage:(BDHandlePackage *)package handleFailTime:(NSInteger)handleFailTime
{
    [self.packageDao replaceWithPackage:package handleFailTime:handleFailTime];
}

-(BOOL)canDownloadPackage:(BDHandlePackage *)package
{
    NSTimeInterval curTime=[[NSDate date] timeIntervalSince1970];
    if ((curTime-package.handleFaildTime)<kPackage_HandleFailTimeInterval)
    {
        return NO;
    }
    return YES;
}


-(void)clearExecutingQueue
{
    [executingQueue removeAllObjects];
}
-(void)clearPackageTable
{
    [self.packageDao clearTable];
}
-(void)clearPackageCache
{
    [self.packages removeAllObjects];
}

#pragma mark-Private Method
-(void)storePackage:(NSArray *)packages orgPackage:(BDHandlePackage *)orgPackage
{
    @autoreleasepool{
        
        for (BDHandlePackage *package in packages)
        {
            NSInteger count=[self.packageDao countWithUrl:package.url];
            //数据库是否已经存在
            if (count)
            {
                continue;
            }
            [self.packageDao replaceWithPackage:package handleFailTime:0];
        }
        
        [self startDownload];
        //回包给服务器 告知已经记住下载路径
        [[BDSpotFlowService sharedService] handleRememberPackage:orgPackage];
        [self resumeTimer];//唤醒定时器
    }
}
//继续定时器
-(void)resumeTimer
{
    if (!_timer)
    {
        return;
    }
    if (![_timer isValid])
    {
        return;
    }
    [_timer setFireDate:[NSDate date]];
}
//暂停定时器
-(void)pauseTimer
{
    if (!_timer)
    {
        return;
    }
    if (![_timer isValid])
    {
        return;
    }
    [_timer setFireDate:[NSDate distantFuture]];
}







@end
