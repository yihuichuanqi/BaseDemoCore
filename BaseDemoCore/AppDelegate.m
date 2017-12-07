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

#pragma mark-CYLTabBarController Delegate
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    [[self cyl_tabBarController] updateSelectionStatusIfNeededForTabBarController:tabBarController shouldSelectViewController:viewController];
    return YES;
}
-(void)tabBarController:(UITabBarController *)tabBarController didSelectControl:(UIControl *)control
{
    UIView *animationView;
    if ([control cyl_isTabButton])
    {
        //更改红标状态
        if ([[self cyl_tabBarController].selectedViewController cyl_isShowTabBadgePoint])
        {
            [[self cyl_tabBarController].selectedViewController cyl_removeTabBadgePoint];
        }
        else
        {
            [[self cyl_tabBarController].selectedViewController cyl_showTabBadgePoint];
        }
        animationView=[control cyl_tabImageView];
    }
    //即使plusButton添加了点击事件 点击同样触发
    if ([control cyl_isPlusButton])
    {
        UIButton *btn=CYLExternPlusButton;
        animationView=btn.imageView;
    }
    if ([self cyl_tabBarController].selectedIndex%2==0)
    {
        //缩放
        [self addTabBarImageScaleAnimationOnView:animationView repeatCount:1];
    }
    else
    {
        //旋转
        [self addTabBarImageaRotateAnimationOnView:animationView];
    }
}
-(void)addTabBarImageScaleAnimationOnView:(UIView *)animationView repeatCount:(float)repeatCount
{
    //需要实现的帧动画 可根据需求自定义
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animation];
    animation.keyPath=@"transform.scale";
    animation.values=@[@1.0,@1.3,@0.9,@1.15,@0.95,@1.02,@1.0];
    animation.duration=1;
    animation.repeatCount=repeatCount;
    animation.calculationMode=kCAAnimationCubic;
    [animationView.layer addAnimation:animation forKey:nil];
}
-(void)addTabBarImageaRotateAnimationOnView:(UIView *)animationView
{
    //针对旋转动画，需要将旋转轴向屏幕外侧平移(最大图片宽度的一半)，否则背景与按钮图片处于同一层次，图片旋转时转轴就在背景图片上，等结束后需要复位
    animationView.layer.zPosition=65.0f/2;
    [UIView animateWithDuration:0.32 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        animationView.layer.transform=CATransform3DMakeRotation(M_PI, 0, 1, 0);
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.70 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            animationView.layer.transform=CATransform3DMakeRotation(2*M_PI, 0, 1, 0);
            
        } completion:nil];
        
    });
    
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
