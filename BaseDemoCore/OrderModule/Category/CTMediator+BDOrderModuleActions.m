//
//  CTMediator+BDOrderModuleActions.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "CTMediator+BDOrderModuleActions.h"


NSString *const kCTMediatorTargetOrder=@"Order";
NSString *const kCTMediatorActionNativeOrderViewController=@"NativeOrderViewController";

@implementation CTMediator (BDOrderModuleActions)

-(UIViewController *)CTMediator_Order_ViewControllerForOrder
{
    return [self CTMediator_Order_ViewControllerForOrder:nil];
}
-(UIViewController *)CTMediator_Order_ViewControllerForOrder:(NSDictionary *)params
{
    UIViewController *viewController=[self performTarget:kCTMediatorTargetOrder action:kCTMediatorActionNativeOrderViewController params:params shouldCacheTarget:YES];
    if ([viewController isKindOfClass:[UIViewController class]])
    {
        return viewController;
    }
    return [[UIViewController alloc]init];
}
@end
