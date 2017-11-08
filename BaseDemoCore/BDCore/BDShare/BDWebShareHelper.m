//
//  BDWebShareHelper.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDWebShareHelper.h"
#import "BDShareHelper.h"
#import "BDShareConfigManager.h"

@implementation BDWebShareHelper

-(void)shareTexrForPlatForm:(NSString *)platformType text:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        [BDShareHelper shareTextDataWithPlatform:[self getPlatformType:platformType] withTextData:text completion:^(id result, NSError *error) {
           
            [self showShareResultView:error];
        }];
        
    });
}
-(void)shareUrlForPlatForm:(NSString *)platformType shareUrl:(NSString *)shareUrl title:(NSString *)title desc:(NSString *)desc thumImageUrl:(NSString *)thumImageUrl
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [BDShareHelper shareUrlDataWithPlatform:[self getPlatformType:platformType] withShareUrlData:shareUrl title:title desc:desc thumImage:thumImageUrl completion:^(id result, NSError *error) {
           
            [self showShareResultView:error];
        }];
        
    });
}
-(void)shareImageTextForPlatForm:(NSString *)platformType shareImageUrl:(NSString *)shareImageUrl title:(NSString *)title desc:(NSString *)desc thumImageUrl:(NSString *)thumImageUrl
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [BDShareHelper shareImagetTexDataWithPlatform:[self getPlatformType:platformType] withShareImageData:shareImageUrl title:title desc:desc thumImage:thumImageUrl completion:^(id result, NSError *error) {
           
            [self showShareResultView:error];
        }];
        
    });
}
#pragma mark-展示结果
-(void)showShareResultView:(NSError *)error
{
    if (error)
    {
        return;
    }
    NSString *alertMessage=BDShareConfigManagerInstance.shareSuccessMessage?:@"分享成功";
    NSLog(@"%@",alertMessage);
}

#pragma mark-获取平台
-(BDSocialPlatformType)getPlatformType:(NSString *)platform
{
    BDSocialPlatformType platType=BDSocialPlatformType_Unknown;
    if ([platform isEqualToString:@"sina"])
    {
        platType=BDSocialPlatformType_Sina;
    }
    else if ([platform isEqualToString:@"wechatSession"])
    {
        platType=BDSocialPlatformType_WechatSesssoin;
    }
    else if ([platform isEqualToString:@"wechatTimeLine"])
    {
        platType=BDSocialPlatformType_WechatTimeLine;
    }
    else if ([platform isEqualToString:@"qq"])
    {
        platType=BDSocialPlatformType_QQ;
    }
    else if ([platform isEqualToString:@"qzone"])
    {
        platType=BDSocialPlatformType_QZone;
    }
    else if ([platform isEqualToString:@"tencetWb"])
    {
        platType=BDSocialPlatformType_TencentWb;
    }
    else
    {
        NSLog(@"分享指定类型不存在，请检查字符串是否正确");
    }
    return platType;
}



@end
