//
//  BDMineConfigManager.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/6.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDMineConfigManager.h"

@implementation BDMineConfigManager

+(BDMineConfigManager *)sharedInstance
{
    static BDMineConfigManager *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[BDMineConfigManager new];
    });
    return instance;
}



@end
