//
//  BDSharePlatformHelper.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDSharePlatformHelper.h"

@implementation BDSharePlatformHelper

+(BOOL)installPlatAppForType:(BDSocialPlatformType)platform
{
    BOOL result=NO;
    
    NSLog(@"需要添加判断");
    return result;
}
+(void)authWithPlatform:(BDSocialPlatformType)platform completion:(BDSocialAuthCompletionHandler)completionHandler
{
    
}
+(void)cancelAuthWithPlatform:(BDSocialPlatformType)platform completion:(BDSocialCancelAuthCompletionHandler)completionHandler
{
    
}
+(void)getUserInfoWithPlatform:(BDSocialPlatformType)platform completion:(BDSocialUserInfoCompletionHandler)completionHandler
{
    
}

@end
