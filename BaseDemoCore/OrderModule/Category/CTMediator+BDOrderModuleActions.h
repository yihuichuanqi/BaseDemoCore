//
//  CTMediator+BDOrderModuleActions.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <CTMediator/CTMediator.h>

@interface CTMediator (BDOrderModuleActions)

-(UIViewController *)CTMediator_Order_ViewControllerForOrder;
-(UIViewController *)CTMediator_Order_ViewControllerForOrder:(NSDictionary *)params;

@end
