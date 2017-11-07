//
//  CTMediator+BDPublicModuleActions.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <CTMediator/CTMediator.h>

@interface CTMediator (BDPublicModuleActions)

-(UIViewController *)CTMediator_Public_ViewControllerForPublic;
-(UIViewController *)CTMediator_Public_ViewControllerForPublic:(NSDictionary *)params;

@end

