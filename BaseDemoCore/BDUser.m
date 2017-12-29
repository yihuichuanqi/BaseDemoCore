//
//  BDUser.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDUser.h"
#import "BDUserManager.h"
@implementation BDUser


+(BDUser *)currentUser
{
    NSDictionary *dic=@{@"userId":@"0000001",@"name":@"王",@"phone":@"1355298",@"email":@"132@qq.com"};
    BDUser *uu=[BDUser initWithServerJson:dic];
    return uu;
}

+(BOOL)isLocalTemporaryUser
{
    //当前内存用户信息为空 则为暂时用户
    BDUserManager *userManager=[BDUserManager sharedManager];
    return userManager.currentManagerUser==nil;
}





@end
