//
//  Target_Public.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "Target_Public.h"
#import "BDPublicViewController.h"

@implementation Target_Public

-(UIViewController *)Action_NativePublicViewController:(NSDictionary *)params
{
    BDPublicViewController *viewController=[[BDPublicViewController alloc]initWithRouterParams:params];
    return viewController;
}
@end
