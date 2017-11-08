//
//  BDShareTool.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDShareConfigManager.h"
@interface BDShareTool : NSObject

//本地分享类型映射到相应第三方分享平台类型

+(NSString *)getThirdSocialPlatformForBDPlatformType:(BDSocialPlatformType)bdPlatform;

@end
