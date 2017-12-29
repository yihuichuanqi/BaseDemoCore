//
//  BDDefaultsConst.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

/*NSUserDefaults 存储Key*/
extern NSString *const BDUserIdentifierDefaults; //用户识别码
extern NSString *const BDUseStagingDefaults; //是否测试环境

//测试服务器地址
extern NSString *const BDStagingApiURLDefaults;
extern NSString *const BDStagingWebURLDefaults;
extern NSString *const BDStagingDeprecatedMobileWebURLDefaults;
extern NSString *const BDStagingMetaphysicsURLDefaults;
extern NSString *const BDStagingLiveSocketURLDefaults;

//用户通行token
extern NSString *const BDAuthTokenDefaults;
extern NSString *const BDAuthTokenExpiryDefaults;
//应用通行token
extern NSString *const BDAppTokenKeyChainKeyDefaults;
extern NSString *const BDAppTokenExpiryDateDefaults;




@interface BDDefaultsConst : NSObject

//默认配置
+(void)setup;
+(void)resetDefaults;
@end
