//
//  CTMediator+BDPublicModuleActions.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "CTMediator+BDPublicModuleActions.h"


NSString *const kCTMediatorTargetPublic=@"Public";
NSString *const kCTMediatorActionNativePublicController=@"NativePublicViewController";
NSString *const kCTMediatorActionNativePublicDetailViewController=@"NativePublicDetailViewController";


@implementation CTMediator (BDPublicModuleActions)

-(UIViewController *)CTMediator_Public_ViewControllerForPublic
{
    return [self CTMediator_Public_ViewControllerForPublic:nil];
}
-(UIViewController *)CTMediator_Public_ViewControllerForPublic:(NSDictionary *)params
{
    UIViewController *viewController=[self performTarget:kCTMediatorTargetPublic action:kCTMediatorActionNativePublicController params:params shouldCacheTarget:YES];
    if ([viewController isKindOfClass:[UIViewController class]])
    {
        return viewController;
    }
    else
    {
        return [[UIViewController alloc]init];
    }
}

-(UIViewController *)CTMediator_Public_ViewControllerForPublicDetail
{
    return [self CTMediator_Public_ViewControllerForPublicDetail:nil];
}
-(UIViewController *)CTMediator_Public_ViewControllerForPublicDetail:(NSDictionary *)params
{
    UIViewController *viewController=[self performTarget:kCTMediatorTargetPublic action:kCTMediatorActionNativePublicDetailViewController params:params shouldCacheTarget:YES];
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
