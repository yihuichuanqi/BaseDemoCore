//
//  BDShareConfigManager.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDShareConfigManager.h"

@implementation BDShareConfigManager

+(BDShareConfigManager *)sharedInstance
{
    static BDShareConfigManager *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[BDShareConfigManager new];
    });
    return instance;
}

-(void)setPaltForm:(BDSocialPlatConfigType)platformType appKey:(NSString *)appKey appSecrect:(NSString *)appSecrect redirectUrl:(NSString *)redirectUrl
{
    switch (platformType) {
        case BDSocialPlatConfigType_Sina:
        {
            self.bdSocialConfig_Sine_AppKey=appKey;
            self.bdSocialConfig_Sine_AppSecrect=appSecrect;
            self.bdSocialConfig_Sine_RedirectUrl=redirectUrl;
        }
            break;
        case BDSocialPlatConfigType_Wechat:
        {
        }
            break;
        case BDSocialPlatConfigType_Tencent:
        {
        }
            break;
        default:
            break;
    }
}

@end
