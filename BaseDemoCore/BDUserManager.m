//
//  BDUserManager.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDUserManager.h"
#import "BDDefaultsConst.h"
#import "NSKeyedUnarchiver+ErrorLogging.h"

#import "BDUser.h"

#import "BDKeyChainUtil.h"
#import "BDFileUtil.h"
#import "BDSystemTimeUtil.h"
#import "BDRouter.h"

#pragma mark- NSNotification
NSString *const BDUserStartedNotification=@"BDUserStartedNotification"; //用户信息更新通知

//局部(临时)变量定义
NSString *BDLocalTemporaryUserNameKey=@"BDLocalTemporaryUserNameKey";
NSString *BDLocalTemporaryUserEmailKey=@"BDLocalTemporaryUserEmailKey";
NSString *BDLocalTemporaryUserUUIDKey=@"BDLocalTemporaryUserUUIDKey";

//无效网页通用凭证
static BOOL BDUserManagerDisableSharedWebCredentials=NO;

@interface BDUserManager ()

@property (nonatomic,strong) BDUser *currentUser;

@property (nonatomic,strong) NSObject<BDKeyChainUtilDelegate> *keyChain;

@end


@implementation BDUserManager

+(instancetype)sharedManager
{
    static BDUserManager *_sharedManager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager=[[BDUserManager alloc]init];
    });
    return _sharedManager;
}
-(instancetype)init
{
    self=[super init];
    if (!self)
    {
        return nil;
    }
    //用户信息存储目录路径
    NSString *userDataPath=[self userDataFilePath];
    //用户信息存储文件路径
    if ([[NSFileManager defaultManager] fileExistsAtPath:userDataPath])
    {
        _currentUser=[NSKeyedUnarchiver unarchiveObjectWithFile:userDataPath exceptionBlock:^id(NSException *exception) {
           
            NSLog(@"UnArchiver User Data Error:%@",exception.reason);
            [[NSFileManager defaultManager] removeItemAtPath:userDataPath error:nil];
            return nil;
        }];
        
        //为了安全访问
        if (!_currentUser.userId)
        {
            NSLog(@"User %@ not have UserId",_currentUser);
            _currentUser=nil;
        }
        
    }
    _keyChain=[[BDKeyChainUtil alloc]init];
    return self;

}

#pragma mark- set get
-(void)setCurrentUser:(BDUser *)currentUser
{
    if (_currentUser!=currentUser)
    {
        _currentUser=currentUser;
        if (currentUser!=nil)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:BDUserStartedNotification object:self];
        }
    }
}
-(BDUser *)currentManagerUser
{
    return _currentUser;
}
-(void)setLocalTemporaryUserName:(NSString *)localTemporaryUserName
{
    if (localTemporaryUserName)
    {
        [self.keyChain setKeyChainStringForKey:BDLocalTemporaryUserNameKey value:localTemporaryUserName];
    }
    else
    {
        [self.keyChain removeKeyChainStringForKey:BDLocalTemporaryUserNameKey];
    }
}
-(NSString *)localTemporaryUserName
{
    return [self.keyChain keyChainStringForKey:BDLocalTemporaryUserNameKey];
}
-(void)setLocalTemporaryUserEmail:(NSString *)localTemporaryUserEmail
{
    if (localTemporaryUserEmail)
    {
        [self.keyChain setKeyChainStringForKey:BDLocalTemporaryUserEmailKey value:localTemporaryUserEmail];
    }
    else
    {
        [self.keyChain removeKeyChainStringForKey:BDLocalTemporaryUserEmailKey];
    }
}
-(NSString *)localTemporaryUserEmail
{
    return [self.keyChain keyChainStringForKey:BDLocalTemporaryUserEmailKey];
}
-(NSString *)localTemporaryUserUUID
{
    NSString *uuid=[self.keyChain keyChainStringForKey:BDLocalTemporaryUserUUIDKey];
    if (!uuid)
    {
        uuid=[[NSUUID UUID] UUIDString];
        [self.keyChain setKeyChainStringForKey:BDLocalTemporaryUserUUIDKey value:uuid];
    }
    return uuid;
}
-(void)resetLocalTemporaryUserUUID
{
    [self.keyChain removeKeyChainStringForKey:BDLocalTemporaryUserUUIDKey];
}

-(void)disableSharedWebCredentials
{
    BDUserManagerDisableSharedWebCredentials=YES;
}

-(void)storeUserData
{
    NSString *userDataPath=[BDFileUtil userDataDocumentsPathWithFile:@"User.data"];
    if (userDataPath)
    {
        //路径存在 则存储
        [NSKeyedArchiver archiveRootObject:self.currentUser toFile:userDataPath];
        
        //NSUserDefaults 存储用户身份标识（UserId）
        [[NSUserDefaults standardUserDefaults] setObject:self.currentUser.userId forKey:BDUserIdentifierDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

+(void)logout
{
    
}

+(void)clearUserData
{
    
}

-(BOOL)hasExistingAccount
{
    return (self.currentUser&&[self hasValidAuthenToken]);
}
-(BOOL)hasValidAuthenToken
{
    //用户token
    NSString *authToken=[self userAuthenToken];
    //过期时长
    NSDate *expiryDate=[[NSUserDefaults standardUserDefaults] objectForKey:BDAuthTokenExpiryDefaults];
//    BOOL tokenValid=expiryDate&&[BDSystemTimeUtil date]
    return YES;
}
-(BOOL)hasValidAppToken
{
    return YES;
}


-(NSString *)userAuthenToken
{
    //内存存在则返回 否则获取钥匙串中存储的
    return _userAuthenToken?:[self.keyChain keyChainStringForKey:BDAuthTokenDefaults];
}


#pragma mark-Private
+(void)clearUserData:(BDUserManager *)manager useStaging:(id)useStaging
{
    //移除User数据
    [manager deleteUserData];
    
    //移除Defaults配置
    [BDDefaultsConst resetDefaults];
    
    //移除钥匙串
    [manager.keyChain removeKeyChainStringForKey:BDAppTokenExpiryDateDefaults];
    [manager.keyChain removeKeyChainStringForKey:BDAppTokenKeyChainKeyDefaults];
    
    //移除Cookies
    [manager deleteHttpCookies];
}

-(void)deleteHttpCookies
{
    NSHTTPCookieStorage *cookieStorage=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies)
    {
        if ([BDRouter.AppHosts containsObject:cookie.domain])
        {
            [cookieStorage deleteCookie:cookie];
        }
    }
}
-(void)deleteUserData
{
    NSString *userDataFolderPath=[self userDataFilePath];
    if (userDataFolderPath)
    {
        NSError *error=nil;
        [[NSFileManager defaultManager] removeItemAtPath:userDataFolderPath error:&error];
        if (error)
        {
            NSLog(@"Error Delete User Data :%@",error.localizedDescription);
        }
    }
}
-(NSString *)userDataFilePath
{
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:BDUserIdentifierDefaults];
    userId=@"100";
    if (!userId)
    {
        return nil;
    }
    return [BDFileUtil userDataDocumentsPathWithFile:@"User.data"];
}





















@end
