//
//  Target_Mine.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "Target_Mine.h"
#import "BDMineViewController.h"

@implementation Target_Mine

-(UIViewController *)Action_NativeMineViewController:(NSDictionary *)params
{
    BDMineViewController *viewController=[[BDMineViewController alloc]initWithRouterParams:params];
    return viewController;
}

@end
