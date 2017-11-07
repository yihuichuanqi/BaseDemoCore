//
//  BDCoreConfigManager.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/6.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDCoreConfigManager.h"

@implementation BDCoreConfigManager

+(BDCoreConfigManager *)sharedInstance
{
    static BDCoreConfigManager *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[BDCoreConfigManager new];
    });
    return instance;
}

-(void)setJsPatchMutableArray:(NSMutableArray *)jsPatchMutableArray
{
    if (jsPatchMutableArray.count>0)
    {
        NSLog(@"开启热更新服务");
    }
}






@end
