//
//  BDZipService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/17.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDZipService.h"
//#import <SSZipArchive/SSZipArchive.h>
#import "SSZipArchive.h"

#import "BDHandlePackage.h"
#import "NSDictionary+BD.h"
#import "NSString+Hash.h"

@interface BDZipService ()<SSZipArchiveDelegate>

@property (nonatomic,strong) NSLock *packageDictLock;
@property (nonatomic,strong) NSMutableDictionary *packageDict; //保存所需解压缩的zip包

@end

@implementation BDZipService

-(NSMutableDictionary *)packageDict
{
    if (!_packageDict)
    {
        _packageDict=[NSMutableDictionary dictionary];
    }
    return _packageDict;
}
-(NSLock *)packageDictLock
{
    if (!_packageDictLock)
    {
        _packageDictLock=[[NSLock alloc]init];
    }
    return _packageDictLock;
}

+(instancetype)sharedService
{
    static BDZipService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDZipService alloc]init];
    });
    return service;
}

-(void)unZipPath:(NSString *)filePath toPath:(NSString *)toPath
{
    [self unZipPath:filePath toPath:toPath package:nil];
}
-(void)unZipPath:(NSString *)filePath toPath:(NSString *)toPath package:(BDHandlePackage *)package
{
    @autoreleasepool{
        NSError *error=nil;
        [self addPackageToDict:package];
        //解压缩方法及密码（已重改）
        BOOL success=[SSZipArchive wdpUnzipFileAtPath:filePath toDestination:toPath error:&error delegate:self];
//        BOOL success=[SSZipArchive unzipFileAtPath:filePath toDestination:toPath overwrite:YES password:@"123" error:&error delegate:self];
        if (!success&&self.delegate &&[self.delegate respondsToSelector:@selector(zipDidFinished:unZipFilePath:success:package:)])
        {
            [self.delegate zipDidFinished:filePath unZipFilePath:toPath success:NO package:package];
            [self removeObjectDict:filePath];
        }
    }
}

-(void)unZipPathWithoutPassword:(NSString *)filePath toPath:(NSString *)toPath
{
    @autoreleasepool{
        
        NSError *error=nil;
        BOOL success=[SSZipArchive unzipFileAtPath:filePath toDestination:toPath overwrite:YES password:nil error:&error delegate:self];
        if (!success&&self.delegate &&[self.delegate respondsToSelector:@selector(zipDidFinished:unZipFilePath:success:package:)])
        {
            [self.delegate zipDidFinished:filePath unZipFilePath:toPath success:NO package:nil];
        }
    }
}


#pragma mark-SSZip delegate
-(void)zipArchiveWillUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo
{
    
}
-(void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(zipDidFinished:unZipFilePath:success:package:)])
    {
        [self.delegate zipDidFinished:path unZipFilePath:unzippedPath success:YES package:[self.packageDict bd_nilObjectForKey:path.md5String forClass:[BDHandlePackage class]]];
    }
    [self removeObjectDict:path];
}
-(void)zipArchiveWillUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(unz_file_info)fileInfo
{
    
}
-(void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath fileInfo:(unz_file_info)fileInfo
{
    
}

#pragma mark-Private Method
-(void)addPackageToDict:(BDHandlePackage *)package
{
    [self.packageDictLock lock];
    [self.packageDict bd_safeSetObject:package forKey:package.zipCachePath.md5String withClass:[package class]];
    [self.packageDictLock unlock];
}
-(void)removeObjectDict:(NSString *)filePath
{
    [self.packageDictLock lock];
    [self.packageDict bd_safeRemoveObjectForKey:filePath.md5String];
    [self.packageDictLock unlock];
}









@end
