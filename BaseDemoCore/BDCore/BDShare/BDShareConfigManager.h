//
//  BDShareConfigManager.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BDShareConfigManagerInstance [BDShareConfigManager sharedInstance]

//配置类型
typedef NS_ENUM(NSInteger,BDSocialPlatConfigType) {
    
    BDSocialPlatConfigType_Sina,
    BDSocialPlatConfigType_Wechat,
    BDSocialPlatConfigType_Tencent,
    
};
//平台类型
typedef NS_ENUM(NSInteger,BDSocialPlatformType) {
    
    BDSocialPlatformType_Unknown,
    BDSocialPlatformType_Sina,
    BDSocialPlatformType_WechatSesssoin, //微信聊天
    BDSocialPlatformType_WechatTimeLine,
    BDSocialPlatformType_QQ,
    BDSocialPlatformType_QZone,
    BDSocialPlatformType_TencentWb, //腾旭微博
};


@interface BDShareConfigManager : NSObject

@property (nonatomic,strong) NSString *shareAppKey;
//是否开启sdk调试
@property (nonatomic,getter=isLogEnabled) BOOL shareLogEnabled;

//其他配置
@property (nonatomic,strong) NSString *shareSuccessMessage;
@property (nonatomic,strong) NSString *shareFailMessage;

//设置新浪
@property (nonatomic,strong) NSString *bdSocialConfig_Sine_AppKey;
@property (nonatomic,strong) NSString *bdSocialConfig_Sine_AppSecrect;
@property (nonatomic,strong) NSString *bdSocialConfig_Sine_RedirectUrl;


//设置微信
//设置腾讯

+(BDShareConfigManager *)sharedInstance;

-(void)setPaltForm:(BDSocialPlatConfigType)platformType appKey:(NSString *)appKey appSecrect:(NSString *)appSecrect redirectUrl:(NSString *)redirectUrl;





@end
