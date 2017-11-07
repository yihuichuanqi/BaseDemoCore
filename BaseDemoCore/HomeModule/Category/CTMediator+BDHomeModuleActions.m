//
//  CTMediator+BDHomeModuleActions.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "CTMediator+BDHomeModuleActions.h"

//模块常亮
NSString *const kCTMediatorTargetHome=@"Home";
NSString *const kCTMediatorActionNativeHomeViewController=@"NativeHomeViewController";

@implementation CTMediator (BDHomeModuleActions)

-(UIViewController *)CTMediator_Home_ViewControllerForHome
{
    return [self CTMediator_Home_ViewControllerForHome:nil];
}
-(UIViewController *)CTMediator_Home_ViewControllerForHome:(NSDictionary *)params
{
    UIViewController *viewController=[self performTarget:kCTMediatorTargetHome action:kCTMediatorActionNativeHomeViewController params:params shouldCacheTarget:YES];
    if ([viewController isKindOfClass:[UIViewController class]])
    {
        return viewController;
    }
    else
    {
        return [[UIViewController alloc]init];
    }
}
@end
