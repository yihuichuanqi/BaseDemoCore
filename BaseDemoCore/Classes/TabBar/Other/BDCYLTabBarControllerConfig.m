//
//  BDCYLTabBarControllerConfig.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/6.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDCYLTabBarControllerConfig.h"
#import "BDBaseNavigationViewController.h"
#import "BDHomeViewController.h"
#import "BDMineViewController.h"
#import "BDPublicViewController.h"

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
    BDHomeViewController *homeVC=[[BDHomeViewController alloc]init];
    BDBaseNavigationViewController *homeNav=[[BDBaseNavigationViewController alloc]initWithRootViewController:homeVC];
    BDMineViewController *mineVC=[[BDMineViewController alloc]init];
    BDBaseNavigationViewController *mineNav=[[BDBaseNavigationViewController alloc]initWithRootViewController:mineVC];
    BDPublicViewController *publicVC=[[BDPublicViewController alloc]init];
    BDBaseNavigationViewController *publicNav=[[BDBaseNavigationViewController alloc]initWithRootViewController:publicVC];

    NSArray *viewControllers=@[homeNav,publicNav,mineNav];
    return viewControllers;
}
-(NSArray *)tabBarItemAttributes
{
    
    NSDictionary *homeDic=@{CYLTabBarItemTitle:@"首页",CYLTabBarItemImage:@"",CYLTabBarItemSelectedImage:@""};
    NSDictionary *mineDic=@{CYLTabBarItemTitle:@"我的",CYLTabBarItemImage:@"",CYLTabBarItemSelectedImage:@""};
    NSDictionary *publicDic=@{CYLTabBarItemTitle:@"发布",CYLTabBarItemImage:@"",CYLTabBarItemSelectedImage:@""};

    NSArray *tabBarItemAttributes=@[homeDic,mineDic,publicDic];
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
