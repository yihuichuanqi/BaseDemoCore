//
//  BDJSPathHelper.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDJSPathHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import "BDJSPathModel.h"

#import <YYCache/YYCache.h>
#import <AFNetworking/AFNetworking.h>

@interface BDJSPathHelper  ()

@property (nonatomic,strong) NSMutableArray *mcPatchs;
@property (nonatomic,strong) NSMutableArray *mcLocalPatchs; //本地补丁信息
@property (nonatomic,copy,readonly) NSString *mcPatchCacheKey; //补丁缓存时所用key

@end


@implementation BDJSPathHelper

-(instancetype)initWithPatchArray:(NSMutableArray *)array
{
    self=[super init];
    if (self)
    {
        self.mcPatchs=array;
    }
    return self;
}

-(NSString *)mcPatchCacheKey
{
    return @"mcJSPatchCacheKey";
}

-(void)setMcPatchs:(NSMutableArray *)mcPatchs
{
    if (mcPatchs.count==0)
    {
        return;
    }
    if (!_mcLocalPatchs)
    {
        _mcLocalPatchs=[[NSMutableArray alloc]init];
    }
    
    //获取本地缓存
    YYCache *myCache=[YYCache cacheWithName:self.mcPatchCacheKey];
    if ([myCache objectForKey:self.mcPatchCacheKey])
    {
        _mcLocalPatchs=(NSMutableArray *)[myCache objectForKey:self.mcPatchCacheKey];
    }
    //先处理所要删除的文件
    for (BDJSPathModel *item in _mcLocalPatchs)
    {
        if (![self existWithArray:mcPatchs model:item])
        {
            //不存在
            if ([self deleteFileWithBDJSPatchModel:item])
            {
                [_mcLocalPatchs removeObject:item];
            }
        }
    }
    //对新补丁进行写入
    for (BDJSPathModel *item in mcPatchs)
    {
        item.status=BDJSPathModelStatus_UnInstall;
        if (![self existWithArray:_mcLocalPatchs model:item]&&[item.ver isEqualToString:[self mcCurrentVer]])
        {
            //本地不存在，需要进行下载 并且只对正确的版本
            [self mcUpdatePatchFile:item];
            [_mcLocalPatchs addObject:item];
        }
    }
    //重新赋值
    [myCache setObject:_mcLocalPatchs forKey:self.mcPatchCacheKey];
    
}

-(void)loadPatchFile
{
    //进行补丁安装
    [self mcUpdateAllLocalPatchFiles];
}
#pragma mark-更新本地所有需要更新的补丁
-(void)mcUpdateAllLocalPatchFiles
{
    if (self.mcLocalPatchs.count==0)
    {
        return;
    }
    __weak typeof(self) weakSelf=self;
    [self.mcLocalPatchs enumerateObjectsUsingBlock:^(BDJSPathModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        __strong typeof(self) self=weakSelf;
        [self mcInstallPatch:obj];
        
    }];
}

#pragma mark-安装单个补丁
-(void)mcInstallPatch:(BDJSPathModel *)patch
{
    //仅（未安装状态）补丁
    if (patch.status!=BDJSPathModelStatus_UnInstall)
    {
        return;
    }
    NSString *path=[self mcPathForModel:patch];
    //本地补丁是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]!=YES)
    {
        //不存在
        patch.status=BDJSPathModelStatus_FileNoxit;
        return;
    }
    //MD5匹配校验
    if ([self mcVerity:path Md5:patch.md5]!=YES)
    {
        //不匹配
        patch.status=BDJSPathModelStatus_FileNoMatch;
        return;
    }
    //补丁是否安装成功
    if ([self mcEvaluateScripFile:path]!=YES)
    {
        patch.status=BDJSPathModelStatus_UnknownError;
        return;
    }
    patch.status=BDJSPathModelStatus_Success;
}
#pragma mark-执行某个JS文件
-(BOOL)mcEvaluateScripFile:(NSString *)path
{
    //打开JSPatch引擎
    
    NSString *scrip=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    if (scrip!=nil)
    {
        //执行修复
        
        return YES;
    }
    return NO;
}

#pragma mark-验证文件MD5是否匹配
-(BOOL)mcVerity:(NSString *)filePath Md5:(NSString *)md5
{
    NSString *fileMd5=[self mcMd5HashOfFilePath:filePath];
    BOOL result=[md5 isEqualToString:fileMd5];
    return result;
}
#pragma mark-获取文件MD5信息
-(NSString *)mcMd5HashOfFilePath:(NSString *)path
{
    NSFileManager *fm=[NSFileManager defaultManager];
    //确保文件存在
    if ([fm fileExistsAtPath:path isDirectory:nil])
    {
        NSData *data=[NSData dataWithContentsOfFile:path];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5(data.bytes, (CC_LONG)data.length, digest);
        NSMutableString *output=[NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
        for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++)
        {
            [output appendFormat:@"%02x",digest[i]];
        }
        return output;
    }
    else
    {
        return @"";
    }
}
#pragma mark-单个更新补丁
-(void)mcUpdatePatchFile:(BDJSPathModel *)patch
{
    if (patch.status==BDJSPathModelStatus_Success)
    {
        return;
    }
    NSString *url=patch.url;
    NSString *savePath=[self mcPathForModel:patch];
    //使用AF下载
    NSURLSessionConfiguration *configuration=[NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager=[[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
    NSURL *requestUrl=[NSURL URLWithString:url];
    NSURLRequest *request=[NSURLRequest requestWithURL:requestUrl];
    NSURLSessionDownloadTask *downloadTask=[manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *)response;
        if (httpResponse.statusCode==200)
        {
            patch.status=BDJSPathModelStatus_UnInstall;
            //保存到本地
            return [NSURL fileURLWithPath:savePath];
        }
        else
        {
            return nil;
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
       
        if (!error)
        {
            NSLog(@"下载完成：%@",filePath);
        }
    }];
    [downloadTask resume];
    
}

#pragma mark-删除文件
-(BOOL)deleteFileWithBDJSPatchModel:(BDJSPathModel *)model
{
    if (!model)
    {
        return NO;
    }
    //文件路径
    NSString *filePath=[self mcPathForModel:model];
    NSFileManager *fm=[NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath])
    {
        return [fm removeItemAtPath:filePath error:nil];
    }
    return NO;
}
#pragma mark-获取某个补丁存储路径
//此方法会根据既定规则计算出补丁应有的路径，但该路径可能暂时无对应文件
-(NSString *)mcPathForModel:(BDJSPathModel *)model
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libCachePath=[[paths objectAtIndex:0] stringByAppendingString:@"/Caches"];
    NSString *patchRootPath=[libCachePath stringByAppendingString:[NSString stringWithFormat:@"/patch/%@",[self mcCurrentVer]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:patchRootPath]==NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:patchRootPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *path=[patchRootPath stringByAppendingString:[NSString stringWithFormat:@"/%@",model.jsPathId]];
    return path;
}
#pragma mark-当前版本号
-(NSString *)mcCurrentVer
{
    NSString *ver=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    return ver;
}


#pragma mark-判断文件是否存在于列表中
-(BOOL)existWithArray:(NSArray *)array model:(BDJSPathModel *)model
{
    BOOL result=NO;
    if (array.count==0)
    {
        return result;
    }
    if (!model)
    {
        return result;
    }
    for (BDJSPathModel *item in array)
    {
        if ([model.jsPathId isEqualToString:item.jsPathId]&&[model.md5 isEqualToString:item.md5])
        {
            result=YES;
            break;
        }
    }
    return result;
}








@end
