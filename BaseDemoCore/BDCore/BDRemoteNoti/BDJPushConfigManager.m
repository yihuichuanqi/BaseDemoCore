//
//  BDJPushConfigManager.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDJPushConfigManager.h"

@implementation BDJPushConfigManager

+(BDJPushConfigManager *)sharesInstance
{
    static BDJPushConfigManager *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[BDJPushConfigManager new];
    });
    return instance;
}
@end
