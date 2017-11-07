//
//  BDCYLTabBarControllerConfig.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/6.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDCYLTabBarControllerConfig.h"
#import "BDBaseNavigationViewController.h"
#import "CTMediator+BDMimeModuleActions.h"
#import "CTMediator+BDHomeModuleActions.h"
#import "CTMediator+BDPublicModuleActions.h"

@interface BDCYLTabBarControllerConfig()<UITabBarControllerDelegate>

@property (nonatomic,readwrite,strong) CYLTabBarController *tabBarController;
@end

@implementation BDCYLTabBarControllerConfig

-(CYLTabBarController *)tabBarController
{
    if (_tabBarController==nil)
    {
        CYLTabBarController *tabBarController=[CYLTabBarController tabBarControllerWithViewControllers:self.viewControllers tabBarItemsAttributes:self.tabBarItemAttributes];
        _tabBarController=tabBarController;
        [self setupTabBarStyleForController:tabBarController];
    }
    return _tabBarController;
}

-(NSArray *)viewControllers
{
    UIViewController *homeVC=[[CTMediator sharedInstance] CTMediator_Home_ViewControllerForHome];
    BDBaseNavigationViewController *homeNav=[[BDBaseNavigationViewController alloc]initWithRootViewController:homeVC];
    UIViewController *mineVC=[[CTMediator sharedInstance] CTMediator_Mine_ViewControllerForMine];
    BDBaseNavigationViewController *mineNav=[[BDBaseNavigationViewController alloc]initWithRootViewController:mineVC];
    UIViewController *publicVC=[[CTMediator sharedInstance] CTMediator_Public_ViewControllerForPublic];
    BDBaseNavigationViewController *publicNav=[[BDBaseNavigationViewController alloc]initWithRootViewController:publicVC];

    NSArray *viewControllers=@[homeNav,publicNav,mineNav];
    return viewControllers;
}
-(NSArray *)tabBarItemAttributes
{
    
    NSDictionary *homeDic=@{CYLTabBarItemTitle:@"首页",CYLTabBarItemImage:@"tab_home_icon",CYLTabBarItemSelectedImage:@"tab_home_click_icon"};
    NSDictionary *mineDic=@{CYLTabBarItemTitle:@"我的",CYLTabBarItemImage:@"tab_mine_icon",CYLTabBarItemSelectedImage:@"tab_mine_click_icon"};
    NSDictionary *publicDic=@{CYLTabBarItemTitle:@"发布",CYLTabBarItemImage:@"tab_discovery_icon",CYLTabBarItemSelectedImage:@"tab_discovery_click_icon"};

    NSArray *tabBarItemAttributes=@[homeDic,publicDic,mineDic];
    return tabBarItemAttributes;
}

#pragma mark-常规设置
//TabBar样式
-(void)setupTabBarStyleForController:(CYLTabBarController *)tabBarController
{
    NSMutableDictionary *normalDic=[NSMutableDictionary dictionary];
    normalDic[NSForegroundColorAttributeName]=[UIColor grayColor];
    NSMutableDictionary *selectDic=[NSMutableDictionary dictionary];
    selectDic[NSForegroundColorAttributeName]=[UIColor darkGrayColor];
    UITabBarItem *tabBarItem=[UITabBarItem appearance];
    [tabBarItem setTitleTextAttributes:normalDic forState:UIControlStateNormal];
    [tabBarItem setTitleTextAttributes:selectDic forState:UIControlStateSelected];
}









@end
