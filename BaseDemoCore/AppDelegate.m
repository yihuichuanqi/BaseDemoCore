//
//  AppDelegate.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/6.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "AppDelegate.h"
#import "BDCoreConfigManager.h"
#import "BDCYLTabBarControllerConfig.h"

@interface AppDelegate ()<UITabBarControllerDelegate,CYLTabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //基础模块配置
    BDCoreConfigManager *bdCoreConfig=[BDCoreConfigManager sharedInstance];
    bdCoreConfig.recordLogger=YES;
    bdCoreConfig.openDebug=NO;
    
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [self setupCYLTabBarController];
    self.window.rootViewController=self.tabBarController;
    self.window.backgroundColor=[UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
#pragma mark-配置TabBarController
-(void)setupCYLTabBarController
{
    BDCYLTabBarControllerConfig *tabBarConfig=[[BDCYLTabBarControllerConfig alloc]init];
    CYLTabBarController *tabBarController=tabBarConfig.tabBarController;
    tabBarController.delegate=self;
    self.tabBarController=tabBarController;
}





-(void)applicationWillResignActive:(UIApplication *)application
{
    [super applicationWillResignActive:application];
}
-(void)applicationDidEnterBackground:(UIApplication *)application
{
    [super applicationDidEnterBackground:application];
}
-(void)applicationWillEnterForeground:(UIApplication *)application
{
    [super applicationWillEnterForeground:application];
}
-(void)applicationDidBecomeActive:(UIApplication *)application
{
    [super applicationDidBecomeActive:application];
}
-(void)applicationWillTerminate:(UIApplication *)application
{
    [super applicationWillTerminate:application];
}

#pragma mark-推送相关处理








@end
