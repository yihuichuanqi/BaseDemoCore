//
//  Target_Home.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "Target_Home.h"
#import "BDHomeViewController.h"

@implementation Target_Home

-(UIViewController *)Action_NativeHomeViewController:(NSDictionary *)params
{
    BDHomeViewController *viewController=[[BDHomeViewController alloc]initWithRouterParams:params];
    return viewController;
}
@end
