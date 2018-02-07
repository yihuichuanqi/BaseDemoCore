//
//  BDConfigService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/18.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDConfigService.h"
#import "BDZipService.h"
#import "BDBasicConfigService.h"
#import "BDMQTTConfigService.h"
#import "BDVehicleConfigService.h"

#import "NSNotificationCenter+MainThread.h"

NSString * const BDConfigDidChangedNotification=@"BDConfigDidChangedNotification";

static NSUInteger const DefaultRequestRetryTime=3U;
static NSTimeInterval const RequestTimeout =480.0;

//配置路径
static NSString * const ConfigRootPathComponent =@"appConfig";
static NSString * const ConfigPackagePathComponent =@"package";
static NSString * const ConfigPackageCachePathComponent =@"packageCache";

@interface BDConfigService ()<BDZipServiceDelegate>
{
    NSUInteger _requestRetryTimes;
}

@property (nonatomic,readonly) BDZipService *zipService;
@property (nonatomic,readonly) NSString *configPackageCachePath;
@property (nonatomic,assign,getter=isMqttNotification) BOOL mqttNotification; //是否是收到mqtt的配置更新命令
@end

@implementation BDConfigService
@synthesize zipService=_zipService;

+(instancetype)sharedService
{
    static BDConfigService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDConfigService alloc]init];
    });
    return service;
}
-(id)init
{
    if (self=[super init])
    {
        [self loadConfigAndAddNotificationObservers];
    }
    return self;
}

-(BDZipService *)zipService
{
    if (!_zipService)
    {
        _zipService=[[BDZipService alloc]init];
        _zipService.delegate=self;
    }
    return _zipService;
}
#pragma mark-ZipDelegate
-(void)zipDidFinished:(NSString *)zipFilePath unZipFilePath:(NSString *)unZipFilePath success:(BOOL)success package:(BDHandlePackage *)package
{
    @autoreleasepool{
        
        //删除缓存
        [[NSFileManager defaultManager] removeItemAtPath:self.configPackageCachePath error:nil];
        if (!success)
        {
            [self retryRequestConfigIfNeeded];
        }
        else
        {
            [self loadConfig];
            if (self.isMqttNotification)
            {
                self.mqttNotification=NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:BDConfigDidChangedNotification object:nil];
            }
            if (![self checkConfig])
            {
                [self retryRequestConfigIfNeeded];
            }
        }
    }
}

-(void)loadConfigAndAddNotificationObservers
{
    [self loadConfig];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestConfig) name:kClearCacheSuccessNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)loadConfig
{
    [[BDBasicConfigService sharedService] loadConfigWithAttributes:[[self getConfigContentForFileName:@"config"] mj_JSONObject]];
    [[BDMQTTConfigService sharedService] loadConfigWithAttributes:[self getConfigContentForFileName:@"mqttConfig"]];
    [[BDVehicleConfigService sharedService] loadConfigWithAttributes:[[self getConfigContentForFileName:@"vehicleMap"] mj_JSONObject]];
    
}
-(NSString *)configRootPath
{
    static NSString *rootPath=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rootPath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:ConfigRootPathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath:rootPath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    return rootPath;
}
-(NSString *)configPackagePath
{
    static NSString *packagePath=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        packagePath=[self.configRootPath stringByAppendingPathComponent:ConfigPackagePathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath:packagePath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:packagePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    return packagePath;
}
-(NSString *)configPackageCachePath
{
    static NSString *cachePath=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachePath=[self.configRootPath stringByAppendingPathComponent:ConfigPackageCachePathComponent];
    });
    return cachePath;
}
//网络加载资源
-(void)requestConfig
{
    [self requestConfigWithRetryTimes:DefaultRequestRetryTime complete:nil];
}
-(void)requestConfigWithRetryTimes:(NSUInteger)retryTimes complete:(void (^)(NSError *))complete
{
    _requestRetryTimes=retryTimes;
    [self requestConfigWithComplete:complete];
}
-(void)requestConfigByMQTTNotification
{
    //防止后台频繁推送导致资源耗尽
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(requestConfigByMQTTNotificationDelay) withObject:nil afterDelay:3];
}


-(BOOL)checkConfig
{
    return YES;
}
#pragma mark-Private Method
-(void)requestConfigByMQTTNotificationDelay
{
    self.mqttNotification=YES;
    [self requestConfigWithRetryTimes:_requestRetryTimes?:DefaultRequestRetryTime complete:nil];
}
-(void)retryRequestConfigIfNeeded
{
    _requestRetryTimes--;
    if (_requestRetryTimes>0)
    {
        [self requestConfigWithComplete:nil];
    }
}
-(void)requestConfigWithComplete:(void(^)(NSError *error))complete
{
    @autoreleasepool{
        
        //删除缓存
        [[NSFileManager defaultManager] removeItemAtPath:self.configPackageCachePath error:nil];
        //下载（时间戳用于标记 后台是否需要返回）
        NSInteger updateTime=[[NSUserDefaults standardUserDefaults] integerForKey:kUCGetConfigTime];
        NSString *urlString=[NSString stringWithFormat:@"%@app/getAppConfig?time=%zd",@"https://app-api.chargerlink.com/",0];
        NSURL *requestUrl=[[NSURL alloc]initWithString:urlString];
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:requestUrl];
        
        AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        NSURLSessionDownloadTask *downloadTask=[manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            
            NSLog(@"download:%f,size=%lld",(float)(downloadProgress.completedUnitCount/downloadProgress.totalUnitCount),downloadProgress.totalUnitCount);

        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            return [NSURL fileURLWithPath:self.configPackageCachePath];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            
            if (error)
            {
                if (_requestRetryTimes>0)
                {
                    _requestRetryTimes--;
                    [self requestConfigWithComplete:complete];
                }
                else
                {
                    if (complete)
                    {
                        complete(error);
                    }
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    @autoreleasepool{
                        
                        [self.zipService unZipPathWithoutPassword:self.configPackageCachePath toPath:self.configPackagePath];
                    }

                });
            }
            
        }];
        [downloadTask resume];
    }
}
-(id) getConfigContentForFileName:(NSString *)fileName
{
    //扩展名
    static NSString * const configFileExtension=@"json";
    NSString *filePath=[[self.configPackagePath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:configFileExtension];
#if DEBUG
    NSLog(@"Config Path:%@",filePath);
#endif
    
    //如果不存在网络配置文件 则读取本地默认配置
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [self unzipDefaultConfig];
    }
    NSString *fileContent=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return fileContent;
}
//解压缩读取本地文件
-(void)unzipDefaultConfig
{
    NSString *defaultPath=[[NSBundle mainBundle] pathForResource:@"config_default" ofType:@"config"];
    [self.zipService unZipPathWithoutPassword:defaultPath toPath:self.configPackagePath];
}



#if DEBUG

-(void)checkConfigImage
{
    
}
#endif








@end
