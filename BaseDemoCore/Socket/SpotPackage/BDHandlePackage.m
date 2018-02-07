//
//  BDHandlePackage.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/17.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDHandlePackage.h"
#import <mach/mach_time.h>
#import "NSDictionary+BD.h"
#import "NSString+Hash.h"

@interface BDHandlePackage ()

//zip Path
+(NSString *)zipDirPath; //包目录
-(NSString *)fileName;

@end

@implementation BDHandlePackage

-(id)initWithDict:(NSDictionary *)dict withMsgId:(NSString *)msgId
{
    return [self initWithDict:dict withMsgId:msgId cmd:0];
}
-(id)initWithDict:(NSDictionary *)dict withMsgId:(NSString *)msgId cmd:(NSInteger)cmd
{
    if (self=[super init])
    {
        self.msgId=msgId;
        self.bodyDict=dict;
        self.cmd=cmd;
        [self detailWithDict:dict];
    }
    return self;
}
-(void)detailWithDict:(NSDictionary *)aDict
{
    self.url=[aDict bd_StringObjectForKey:@"url"];
    self.urlRoot=[aDict bd_StringObjectForKey:@"urlRoot"];
    self.packages=[aDict bd_StringObjectForKey:@"packages"];
    self.isFirst=[[aDict bd_StringObjectForKey:@"isFirst"] boolValue];
    self.updateTime=[aDict bd_IntergerForKey:@"updated_time"];
    self.handleFaildTime=[aDict bd_IntergerForKey:@"handleFailTime"];
    self.packageOrderBy=[aDict bd_IntergerForKey:@"packageOrder"];
}
#pragma mark-Get
-(NSString *)url
{
    if (_url)
    {
        if ([_url hasPrefix:@"http"]||[_url hasPrefix:@"https"])
        {
            return _url;
        }
        _url=[NSString stringWithFormat:@"%@%@",@"https://app-api.chargerlink.com/",_url];
    }
    return _url;
}
-(NSString *)key
{
    if (!_key)
    {
        _key=[NSString stringWithFormat:@"%@-%@",self.url,@(mach_absolute_time())].md5String;
    }
    return _key;
}


-(BOOL)hasUrl
{
    //单包存在url 多包并且存在urlRoot
    if (_url.length||(_urlRoot.length&&self.isMulPackages))
    {
        return YES;
    }
    return NO;
}
-(BOOL)isEqualToPackage:(BDHandlePackage *)package
{
    if ([self.url isEqualToString:package.url]&&[self.msgId isEqualToString:package.msgId]&&self.updateTime==package.updateTime)
    {
        return YES;
    }
    return NO;
}

-(NSInteger)subCmd
{
    NSInteger subCmd=0;
    if (self.bodyDict.count)
    {
        subCmd=[self.bodyDict bd_IntergerForKey:@"subCmd"];
    }
    return subCmd;
}
-(BOOL)isMulPackages
{
    if (self.packages.length)
    {
        if ([self.packages containsString:@","])
        {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isFirstOrSpotPackage
{
    if (self.isFirst)
    {
        return YES;
    }
    if (self.isSpotPackage)
    {
        return YES;
    }
    return NO;
}

-(NSString *)zipCachePath
{
    //zip压缩包缓存目录
    NSString *zipDir=[[[self class] zipDirPath] stringByAppendingPathComponent:@"zipCacheDir"];
    NSFileManager *fm=[NSFileManager defaultManager];
    if (![fm fileExistsAtPath:zipDir])
    {
        [fm createDirectoryAtPath:zipDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [zipDir stringByAppendingPathComponent:[self fileName]];
}
-(NSString *)unZipCachePath
{
    //zip解压包缓存目录
    NSString *unZipDir=[[[self class] zipDirPath] stringByAppendingPathComponent:@"unZipCacheDir"];
    NSFileManager *fm=[NSFileManager defaultManager];
    if (![fm fileExistsAtPath:unZipDir])
    {
        [fm createDirectoryAtPath:unZipDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [unZipDir stringByAppendingPathComponent:[self fileName]];
}

//手动构造package 用于第一次启动时加载数据
+(BDHandlePackage *)package:(NSString *)url
{
    BDHandlePackage *package=[[BDHandlePackage alloc]init];
    package.msgId=url.md5String;
    package.isSpotPackage=YES;
    package.url=url;
    package.cmd=0;
    package.updateTime=0;
    return package;
    
}
+(BDHandlePackage *)package:(NSDictionary *)dict msgId:(NSString *)msgId
{
    BDHandlePackage *package=[[BDHandlePackage alloc]initWithDict:dict withMsgId:msgId];
    return package;
}
+(BDHandlePackage *)package:(NSDictionary *)dict msgId:(NSString *)msgId cmd:(NSInteger)cmd
{
    BDHandlePackage *package=[[BDHandlePackage alloc]initWithDict:dict withMsgId:msgId cmd:cmd];
    return package;
}






#pragma mark-Zip 相关
+(NSString *)zipDirPath
{
    static NSString *zipDir=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //zip包归档路径
        NSString *path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"bdZipArchive"];
        NSFileManager *fm=[NSFileManager defaultManager];
        if(![fm fileExistsAtPath:path])
        {
            [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        zipDir=path;
        
    });
    return zipDir;
}
-(NSString *)fileName
{
    //需要做md5
    return self.url.md5String;
}


@end


@implementation BDHandlePackageDao

-(instancetype)init
{
    if (self=[super init])
    {
        [self buildProperties];
        [self updateColumns];
    }
    return self;
}

#pragma mark-BDDaoProtocolDelegate
-(void)buildProperties
{
    if(!self.propertyList)
    {
        self.propertyList=[[BDSqlitePropertyList alloc]init];
    }
    //URL作为主键
    [self.propertyList addFieldName:@"url" serverFieldName:@"url" isPrimaryKey:YES modelDataType:kModelDataTypeString];
    [self.propertyList addFieldName:@"packageOrder" serverFieldName:@"packageOrder" modelDataType:kModelDataTypeInterger];//包顺序
    [self.propertyList addFieldName:@"updatedTime" serverFieldName:@"updated_time" modelDataType:kModelDataTypeInterger];
    [self.propertyList addFieldName:@"handleFailTime" serverFieldName:@"handleFailTime" modelDataType:kModelDataTypeInterger];
    [self.propertyList addFieldName:@"isFirst" serverFieldName:@"isFirst" modelDataType:kModelDataTypeBool];
    
}
-(Class)modelClass
{
    return [BDHandlePackage class];
}
-(NSString *)tableName
{
    return @"tHandlePackage";
}

-(NSInteger)countWithUrl:(NSString *)url
{
    __block NSInteger count=0;
    NSMutableString *sql=[NSMutableString stringWithFormat:@"SELECT count(*) AS dbCount FROM %@",self.tableName];
    NSString *where=nil;
    if (!isEmpty(url))
    {
        where=[NSString stringWithFormat:@"url='%@'",url];
    }
    if (!isEmpty(where))
    {
        [sql appendFormat:@" WHRER %@",where];
    }
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
       
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next])
        {
            count=@([rs intForColumn:@"dbCount"]).integerValue;
        }
    }];
    return count;
}

-(NSArray *)getAllPackagesWithEachBlock:(void (^)(id))eachBlock
{
    NSString *sql=[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY updatedTime, packageOrder",self.tableName];
    return [self modelsWithSQL:sql eachBlock:eachBlock];
}
-(NSArray *)getFirstPackages
{
    NSString *sql=[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY updatedTime, packageOrder LIMIT 1 OFFSET 0",self.tableName];
    return [self modelsWithSQL:sql eachBlock:nil];

}
-(void)replaceWithPackage:(BDHandlePackage *)package handleFailTime:(NSInteger)handleFailTime
{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict bd_safeSetObject:package.url forKey:@"url"];
    [dict bd_safeSetObject:@(package.updateTime) forKey:@"updated_time"];
    [dict bd_safeSetObject:@(handleFailTime) forKey:@"handleFailTime"];
    [dict bd_safeSetObject:@(package.isFirst) forKey:@"isFirst"];
    [dict bd_safeSetObject:@(package.packageOrderBy) forKey:@"packageOrder"];
    [self batchReplaceToTable:@[dict]];
}
-(BOOL)deletePackageWithUrl:(NSString *)url
{
    if (isEmpty(url))
    {
        return NO;
    }
    NSString *where=[NSString stringWithFormat:@"url='%@'",url];
    return [self deleteFromTable:where];
}

@end














