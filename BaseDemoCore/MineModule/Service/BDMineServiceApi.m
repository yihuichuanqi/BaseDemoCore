//
//  BDMineServiceApi.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDMineServiceApi.h"
#import "BDMineConfigManager.h"
@implementation BDMineServiceApi
-(NSString *)requestUrl
{
    return [NSString stringWithFormat:@"%@%@",BDMineConfigManagerInstance.prefixNetworkUrl,@"mine/data"];
}
-(YTKRequestMethod)requestMethod
{
    return YTKRequestMethodGET;
}

@end
