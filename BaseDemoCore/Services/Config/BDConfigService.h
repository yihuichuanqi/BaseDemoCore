//
//  BDConfigService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/18.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*用于统一管理管理各种配置文件*/

#import <Foundation/Foundation.h>

//清除缓存成功通知
#define kClearCacheSuccessNotification @"kClearCacheSuccessNotification"

extern NSString * const BDConfigDidChangedNotification;


@interface BDConfigService : NSObject

+(instancetype)sharedService;

//配置文件根路径
@property (nonatomic,readonly) NSString *configRootPath;
//配置包路径
@property (nonatomic,readonly) NSString *configPackagePath;


-(void)loadConfig;
-(void)requestConfig;
-(void)requestConfigByMQTTNotification;
-(void)requestConfigWithRetryTimes:(NSUInteger)retryTimes complete:(void(^)(NSError *error))complete;

#if DEBUG
-(void)checkConfigImage;
#endif



@end
