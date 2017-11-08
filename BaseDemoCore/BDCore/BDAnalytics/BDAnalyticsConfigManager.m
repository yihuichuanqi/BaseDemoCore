//
//  BDAnalyticsConfigManager.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDAnalyticsConfigManager.h"

@implementation BDAnalyticsConfigManager

+(BDAnalyticsConfigManager *)sharedInstance
{
    static BDAnalyticsConfigManager *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[BDAnalyticsConfigManager new];
    });
    return instance;
}



@end
