//
//  Target_Order.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "Target_Order.h"
#import "BDOrderViewController.h"

@implementation Target_Order

-(UIViewController *)Action_NativeOrderViewController:(NSDictionary *)params
{
    BDOrderViewController *viewController=[[BDOrderViewController alloc]init];
    return viewController;
}
@end
