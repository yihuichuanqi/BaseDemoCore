//
//  BDSpotFlowService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/17.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDSpotFlowService.h"
#import "BDZipService.h"
#import "BDSpotService.h"
#import "BDHandlePackage.h"
#import "BDPackageService.h"

//解压缩后文件名称
static NSString *unZipFileName =@"spots.json";

@interface BDSpotFlowService ()<BDZipServiceDelegate>

@property (nonatomic,strong) NSOperationQueue *operationQueue;
@property (nonatomic,strong) BDZipService *zipService;

@end

@implementation BDSpotFlowService
@synthesize commonDelegates=_commonDelegates;

-(NSHashTable *)commonDelegates
{
    if (!_commonDelegates)
    {
        _commonDelegates=[NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _commonDelegates;
}

-(NSOperationQueue *)operationQueue
{
    if (!_operationQueue)
    {
        _operationQueue=[[NSOperationQueue alloc]init];
        _operationQueue.maxConcurrentOperationCount=1;
    }
    return _operationQueue;
}
-(BDZipService *)zipService
{
    if (!_zipService)
    {
        _zipService=[BDZipService sharedService];
        _zipService.delegate=self;
    }
    return _zipService;
}

#pragma mark-BDZipService Ddelegate
-(void)zipDidFinished:(NSString *)zipFilePath unZipFilePath:(NSString *)unZipFilePath success:(BOOL)success package:(BDHandlePackage *)package
{
    if (!success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
           
            @autoreleasepool{
                
                [self handleFailureWithPackage:package];
            }
        });
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            @autoreleasepool{
                
                NSString *jsonPath=[unZipFilePath stringByAppendingPathComponent:unZipFileName];
                NSData *data=[NSData dataWithContentsOfFile:jsonPath];
                if (!data)
                {
                    //对应解压缩包内容为空或无效
                    [self handleFailureWithPackage:package];
                }
                else
                {
                    NSString *spotsString=nil;
                    for (NSUInteger i=data.length; i>0; i--)
                    {
                        NSString *str=[[NSString alloc]initWithBytes:data.bytes length:i encoding:NSUTF8StringEncoding];
                        NSDictionary *dict=[str mj_JSONObject];
                        if (dict)
                        {
                            spotsString=str;
                            break;
                        }
                    }
                    if (self.delegate && [self.delegate respondsToSelector:@selector(unzipData:package:)])
                    {
                        [self.delegate unzipData:spotsString package:package];
                    }
                    else
                    {
                        [self handleFailureWithPackage:package];
                    }
                }
                //移除下载链接
                NSError *error;
                NSFileManager *fm=[NSFileManager defaultManager];
                [fm removeItemAtPath:zipFilePath error:&error];
                [fm removeItemAtPath:unZipFilePath error:&error];
            }
        });
    }
}

+(instancetype)sharedService
{
    static BDSpotFlowService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDSpotFlowService alloc]init];
    });
    return service;
}

-(void)handleDownloadSpotZip
{
    //如果还不存在数据 则先http拉取一个包
    NSInteger time=[[NSUserDefaults standardUserDefaults] integerForKey:kUCGetSpotsTime];
    if (time<=0)
    {
        //zip包下载路径构造
        BDHandlePackage *package=[BDHandlePackage package:@"spot/getSpotPackage"];
        [self handleDownloadWithPackage:package];
    }
}
-(void)handleDownloadWithPackage:(BDHandlePackage *)package
{
    @autoreleasepool{
        
        NSFileManager *fm=[NSFileManager defaultManager];
        //检查zip文件目录是否存在
        NSString *zipPath=package.zipCachePath;
        if([fm fileExistsAtPath:zipPath])
        {
            [fm removeItemAtPath:zipPath error:nil];
        }
        //下载附件
        NSURL *requestUrl=[[NSURL alloc]initWithString:package.url];
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:requestUrl];
        AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        NSURLSessionDownloadTask *downloadTask=[manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            
            NSLog(@"download:%f,size=%lld",(float)(downloadProgress.completedUnitCount/downloadProgress.totalUnitCount),downloadProgress.totalUnitCount);
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            //服务器端文件名称
            NSLog(@"服务端文件名称:%@",response.suggestedFilename);
            return [NSURL fileURLWithPath:zipPath];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            if(error)
            {
                if (error.code==404)
                {
                    //如果404 表示服务器也不存在此包 则本地数据库删除这条下载路径
                    [self handleSuccessWithPackage:package];
                }
                else
                {
                    //下载失败
                    [self handleFailureWithPackage:package];
                }
            }
            else
            {
                //另开辟个线程
                NSBlockOperation *blockOperation=[NSBlockOperation blockOperationWithBlock:^{
                   
                    @autoreleasepool{
                     
                        [self.zipService unZipPath:zipPath toPath:package.unZipCachePath package:package];
                    }
                }];
                blockOperation.queuePriority=NSOperationQueuePriorityVeryHigh;
                [self.operationQueue addOperation:blockOperation];
            }
            
        }];
        [downloadTask resume];
    }
}

-(void)handleSuccessWithPackage:(BDHandlePackage *)package
{
    if (!package.isSpotPackage)
    {
        [[BDPackageService sharedService] endDownloadWith:package];
    }
}
-(void)handleFailureWithPackage:(BDHandlePackage *)package
{
    if (!package.isSpotPackage&&![[BDPackageService sharedService] canDownloadPackage:package])
    {
        //距离上次下载或者解压缩失败相隔小于5分钟 不重试
        return;
    }
    BDPackageService *packageService=[BDPackageService sharedService];
    if(!package.isSpotPackage)
    {
        //记录失败时间
        NSTimeInterval curTime=[[NSDate date] timeIntervalSince1970];
        [packageService replacePackageInfoWithPackage:package handleFailTime:curTime];
        [packageService clearPackageCache];
        
    }
    if (!package.isSpotPackage)
    {
        [self handleSendVersionToServer];
    }
    [packageService clearExecutingQueue];
    
}

-(void)handleSpotStatusPackage:(BDHandlePackage *)package
{
    @autoreleasepool{
        
        if (self.delegate&&[self.delegate respondsToSelector:@selector(spotStatus:package:)])
        {
            [self.delegate spotStatus:package.bodyDict package:package];
        }
    }
}

-(void)handleRememberPackage:(BDHandlePackage *)package
{
    NSInteger time=[[NSUserDefaults standardUserDefaults] integerForKey:kUCGetSpotsTime];
    if (!package.isSpotPackage&&(package.isFirst||time>0))
    {
        [[NSUserDefaults standardUserDefaults] setInteger:package.updateTime forKey:kUCGetSpotsTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}








@end
