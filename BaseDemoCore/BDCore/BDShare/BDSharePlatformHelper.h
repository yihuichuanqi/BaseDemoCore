//
//  BDSharePlatformHelper.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDShareConfigManager.h"

//授权
typedef void (^BDSocialAuthCompletionHandler)(NSString *uid,NSString *openId,NSString *accessToken,NSError *error);
//取消授权
typedef void (^BDSocialCancelAuthCompletionHandler)(id result,NSError *error);
//获取用户(gender 性别)
typedef void (^BDSocialUserInfoCompletionHandler)(NSString *name,NSString *iconUrl,NSString *gender,NSError *error);

@interface BDSharePlatformHelper : NSObject

@property (nonatomic,copy) BDSocialAuthCompletionHandler socialAuthCompletionBlock;
@property (nonatomic,copy) BDSocialCancelAuthCompletionHandler socialCancelAuthCompletionBlock;
@property (nonatomic,copy) BDSocialUserInfoCompletionHandler socialUserInfoCompletionBlock;

+(BOOL)installPlatAppForType:(BDSocialPlatformType)platform;

+(void)authWithPlatform:(BDSocialPlatformType)platform completion:(BDSocialAuthCompletionHandler)completionHandler;
+(void)cancelAuthWithPlatform:(BDSocialPlatformType)platform completion:(BDSocialCancelAuthCompletionHandler)completionHandler;
+(void)getUserInfoWithPlatform:(BDSocialPlatformType)platform completion:(BDSocialUserInfoCompletionHandler)completionHandler;

@end
