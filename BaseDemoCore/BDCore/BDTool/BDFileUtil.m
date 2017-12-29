//
//  BDFileUtil.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDFileUtil.h"
#import "BDUser.h"

//文件目录
static NSString *_userDocumentsDirectory=nil;
static NSString *_cachesDirectory=nil;
static NSString *_appSupportDirectory=nil;

@implementation BDFileUtil


+(void)initialize
{
    NSFileManager *fm=[NSFileManager defaultManager];
    _userDocumentsDirectory=[[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0] relativePath];
    _cachesDirectory=[[fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask][0] relativePath];
    _appSupportDirectory=[[fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask][0] relativePath];
}

+(NSString *)userDataDocumentsFolder
{
    if(![BDUser currentUser])
        return nil;
    return [_userDocumentsDirectory stringByAppendingPathComponent:[BDUser currentUser].userId];
}

+(NSString *)userDataDocumentsPathWithFile:(NSString *)fileName
{
    if(![BDUser currentUser])
        return nil;
    return [self pathWithFolder:_userDocumentsDirectory folderName:[BDUser currentUser].userId fileName:fileName];
}
+(NSString *)userDataDocumentsPathWithFolder:(NSString *)folderName fileName:(NSString *)fileName
{
    if(![BDUser currentUser])
        return nil;
    folderName=[[BDUser currentUser].userId stringByAppendingPathComponent:folderName];
    return [self pathWithFolder:_userDocumentsDirectory folderName:folderName fileName:fileName];
}


+(NSString *)cachesFolder
{
    return _cachesDirectory;
}
+(NSString *)cachesPathWithFolder:(NSString *)folderName fileName:(NSString *)fileName
{
    return [self pathWithFolder:_cachesDirectory folderName:folderName fileName:fileName];
}

+(NSString *)appDocumentsPathWithFolder:(NSString *)folderName fileName:(NSString *)fileName
{
    return [self pathWithFolder:_userDocumentsDirectory folderName:folderName fileName:fileName];
}

+(NSString *)appSupportFolder
{
    return [self pathWithFolder:_appSupportDirectory folderName:[[NSBundle mainBundle] bundleIdentifier] fileName:nil];
}
+(NSString *)appSupportPathWithFolder:(NSString *)folderName fileName:(NSString *)fileName
{
    if (folderName)
    {
        return [self pathWithFolder:self.appSupportFolder folderName:folderName fileName:fileName];
    }
    else
    {
        return [self.appSupportFolder stringByAppendingPathComponent:fileName];
    }
}



#pragma mark- Private
//文件路径
+(NSString *)pathWithFolder:(NSString *)rootFolderName folderName:(NSString *)folderName fileName:(NSString *)fileName
{
    //目录名称
    NSString *directory=folderName?[rootFolderName stringByAppendingPathComponent:folderName]:rootFolderName;
    if(![[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:nil])
    {
        //不存在则创建目录
        NSError *error=nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
        {
            NSLog(@"Error [%@] Create Directory path %@/%@",[error userInfo],rootFolderName,folderName);
            return nil;
        }
    }
    return fileName?[directory stringByAppendingPathComponent:fileName]:directory;
}






@end
