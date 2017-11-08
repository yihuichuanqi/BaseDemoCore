//
//  BDShareHelper.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDShareConfigManager.h"

//授权 分享等操作回调
typedef void (^BDSocialShareCompletionHandler)(id result,NSError *error);

@interface BDShareHelper : NSObject

@property (nonatomic,copy) BDSocialShareCompletionHandler shareCompletionBlock;

//纯文本分享
+(void)shareTextDataWithPlatform:(BDSocialPlatformType)platformType withTextData:(NSString *)text completion:(BDSocialShareCompletionHandler)completionHandler;
//URL分享
+(void)shareUrlDataWithPlatform:(BDSocialPlatformType)paltformType withShareUrlData:(NSString *)shareUrl title:(NSString *)title desc:(NSString *)desc thumImage:(id)thumImage completion:(BDSocialShareCompletionHandler)completionHandler;
//图文分享
+(void)shareImagetTexDataWithPlatform:(BDSocialPlatformType)paltformType withShareImageData:(id)shareImage title:(NSString *)title desc:(NSString *)desc thumImage:(id)thumImage completion:(BDSocialShareCompletionHandler)completionHandler;
//视频分享
+(void)shareVideoDataWithPlatform:(BDSocialPlatformType)paltformType withShareVideoUrl:(NSString *)shareVideoUrl title:(NSString *)title desc:(NSString *)desc thumImage:(id)thumImage completion:(BDSocialShareCompletionHandler)completionHandler;
//音乐分享
+(void)shareMusicDataWithPlatform:(BDSocialPlatformType)paltformType withShareMusicUrl:(NSString *)shareMusicUrl title:(NSString *)title desc:(NSString *)desc thumImage:(id)thumImage completion:(BDSocialShareCompletionHandler)completionHandler;
@end
