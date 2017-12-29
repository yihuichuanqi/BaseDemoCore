//
//  BDUserManager.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BDUser;
@interface BDUserManager : NSObject

@property (nonatomic,strong) NSString *userAuthenToken; //用户认证token
//临时用户信息
@property (nonatomic,strong,readonly) NSString *localTemporaryUserUUID;
@property (nonatomic,strong) NSString *localTemporaryUserName;
@property (nonatomic,strong) NSString *localTemporaryUserEmail;


+(instancetype)sharedManager;

//清空用户数据
+(void)clearUserData;
//退出登录
+(void)logout;

//获取存储用户信息
-(BDUser *)currentManagerUser;
-(void)storeUserData;

//是否存在账户信息
-(BOOL)hasExistingAccount;
//是否存在有效token
-(BOOL)hasValidAuthenToken;
-(BOOL)hasValidAppToken;

//重置临时UUID
-(void)resetLocalTemporaryUserUUID;

//置网页凭证无效
-(void)disableSharedWebCredentials;







@end
