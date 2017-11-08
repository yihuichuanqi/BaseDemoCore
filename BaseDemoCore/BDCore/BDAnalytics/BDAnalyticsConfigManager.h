//
//  BDAnalyticsConfigManager.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BDAnalyticsConfigManagerInstance [BDAnalyticsConfigManager sharedInstance]

@interface BDAnalyticsConfigManager : NSObject

+(BDAnalyticsConfigManager *)sharedInstance;

@property (nonatomic,strong) NSString *analyticsAppKey;
@property (nonatomic,strong) NSString *analyticsChannelId;
@property (nonatomic,getter=isLogEnabled) BOOL analyticsLogEnabled;
@property (nonatomic) BOOL bCrashReportEnabled; //是否开启闪退记录

@property (nonatomic,strong) NSArray *prefixFilterArray; //要统计页面的前缀字符串
@property (nonatomic,strong) NSArray *filterNameArray; //要统计页面名称字符串
@property (nonatomic,strong) NSArray *noFilterNameArray;//不统计页面名称字符串






@end
