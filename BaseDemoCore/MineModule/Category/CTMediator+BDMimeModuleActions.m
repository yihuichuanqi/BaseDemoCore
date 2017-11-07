//
//  CTMediator+BDMimeModuleActions.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "CTMediator+BDMimeModuleActions.h"



//模块
NSString *const kCTMediatorTargetA=@"Mine";
NSString *const kCTMediatorActionNativeMineViewController=@"NativeMineViewController";

@implementation CTMediator (BDMimeModuleActions)


-(UIViewController *)CTMediator_Mine_ViewControllerForMine
{
    return [self CTMediator_Mine_ViewControllerForMine:nil];
}
-(UIViewController *)CTMediator_Mine_ViewControllerForMine:(NSDictionary *)params
{
    UIViewController *viewController=[self performTarget:kCTMediatorTargetA action:kCTMediatorActionNativeMineViewController params:params shouldCacheTarget:YES];
    if ([viewController isKindOfClass:[UIViewController class]])
    {
        return viewController;
    }
    else
    {
        //处理异常场景
        return [[UIViewController alloc]init];
    }
}



@end
