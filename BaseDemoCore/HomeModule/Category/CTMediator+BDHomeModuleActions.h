//
//  CTMediator+BDHomeModuleActions.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <CTMediator/CTMediator.h>

@interface CTMediator (BDHomeModuleActions)

-(UIViewController *)CTMediator_Home_ViewControllerForHome;
-(UIViewController *)CTMediator_Home_ViewControllerForHome:(NSDictionary *)params;


-(UIViewController *)CTMediator_Home_ViewControllerForHomeList;
-(UIViewController *)CTMediator_Home_ViewControllerForHomeList:(NSDictionary *)params;

@end
