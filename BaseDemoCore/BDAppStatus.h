//
//  BDAppStatus.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/22.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDAppStatus : NSObject

//运行在本地（开发版本）
+(BOOL)isDev;
//苹果官方的Beta版本
+(BOOL)isBeta;
+(BOOL)isBetaOrDev;
//是否是本公司邮箱注册用户
+(BOOL)isBetaDevOrAdmin;

//demo（发布版本Release）
+(BOOL)isDemo;
//是否测试版本
+(BOOL)isRunningTests;


@end
