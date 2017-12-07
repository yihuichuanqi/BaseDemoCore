//
//  BDProgressHud.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/13.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDProgressHud.h"
#import <MBProgressHUD+WJExtension/MBProgressHUD+WJExtension.h>

//#define Chinese_MBProgressHud_System(x) [UIFont fontWithName:@"Heiti SC" size:x]
#define Chinese_MBProgressHud_System(x) [UIFont boldSystemFontOfSize:x]

@interface BDProgressView : MBProgressHUD

@end

@implementation BDProgressView

#pragma mark-优先显示在自定义view上
+(void)showBDHudViewWithIcon:(NSString *)iconName Message:(NSString *)message ToView:(UIView *)view isWindow:(BOOL)isWindow
{
    if(view==nil)
    {
        view=isWindow?(UIView *)[UIApplication sharedApplication].delegate.window:[self getCurrentUIVC].view;
    }
    [BDProgressView wj_showIcon:[UIImage imageNamed:iconName] message:message view:view];
}
+(void)showBDHudViewWithIcon:(NSString *)iconName Message:(NSString *)title ToView:(UIView *)view
{
    [self showBDHudViewWithIcon:iconName Message:title ToView:view isWindow:YES];
}

+(void)showBDHudView:(NSString *)title ToView:(UIView *)view Retime:(CGFloat)time
{
    [self showBDHudView:title ToView:view Retime:time ToWindow:NO];
}
+(void)showBDHudView:(NSString *)title ToView:(UIView *)view Retime:(CGFloat)time ToWindow:(BOOL)isWindow
{
    if(view==nil)
    {
        view=isWindow?(UIView *)[UIApplication sharedApplication].delegate.window:[self getCurrentUIVC].view;
    }
    [BDProgressView wj_showPlainText:title hideAfterDelay:time view:view];
}

+(void)showBDHudView:(NSString *)title ToView:(UIView *)view
{
    [self showBDHudView:title ToView:view ToWindow:NO];
}
+(void)showBDHudView:(NSString *)title ToView:(UIView *)view ToWindow:(BOOL)isWindow
{
    if(view==nil)
    {
        view=isWindow?(UIView *)[UIApplication sharedApplication].delegate.window:[self getCurrentUIVC].view;
    }
    [BDProgressView wj_showPlainText:title view:view];
}


+(void)showBDIconHudView:(NSString *)title ToView:(UIView *)view Retime:(CGFloat)time ToWindow:(BOOL)isWindow
{
    if(view==nil)
    {
        view=isWindow?(UIView *)[UIApplication sharedApplication].delegate.window:[self getCurrentUIVC].view;
    }
    BDProgressView  *hud=[BDProgressView wj_showActivityLoading:title toView:view];
    [hud hide:YES afterDelay:time];
}
+(void)showBDIconHudView:(NSString *)title ToView:(UIView *)view Retime:(CGFloat)time
{
    [self showBDIconHudView:title ToView:view Retime:time ToWindow:NO];
}

+(void)showBDHudLoadingView:(NSString *)title ToView:(UIView *)view
{
    [self showBDHudLoadingView:title ToView:view ToWindow:NO];
}

+(void)showBDHudLoadingView:(NSString *)title ToView:(UIView *)view ToWindow:(BOOL)isWindow
{
    if(view==nil)
    {
        view=isWindow?(UIView *)[UIApplication sharedApplication].delegate.window:[self getCurrentUIVC].view;
    }
    [BDProgressView wj_showActivityLoading:title toView:view];
}

+(void)hideBDHudProgressView:(UIView *)view ToWindow:(BOOL)isWindow
{
    if(view==nil)
    {
        view=isWindow?(UIView *)[UIApplication sharedApplication].delegate.window:[self getCurrentUIVC].view;
    }
    [BDProgressView wj_hideHUDForView:view];
}
+(void)hideMBProgressView:(UIView *)view
{
    [self hideBDHudProgressView:view ToWindow:NO];
}

#pragma mark-获取当前视图控制器
+(UIViewController *)getCurrentWindowVC
{
    UIViewController *result=nil;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    if (window.windowLevel!=UIWindowLevelNormal)
    {
        NSArray *windows=[[UIApplication sharedApplication] windows];
        for (UIWindow *temp in windows)
        {
            if (temp.windowLevel==UIWindowLevelNormal)
            {
                window=temp;
                break;
            }
        }
    }
    UIView *frontView=[[window subviews] objectAtIndex:0];
    id nextResponder=[frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        result=nextResponder;
    }
    else
    {
        result=window.rootViewController;
    }
    return result;
}
+(UIViewController *)getCurrentUIVC
{
    UIViewController *superVC=[[self class] getCurrentWindowVC];
    if ([superVC isKindOfClass:[UITabBarController class]])
    {
        UIViewController *tabBarSelectVC=((UITabBarController *)superVC).selectedViewController;
        if ([tabBarSelectVC isKindOfClass:[UINavigationController class]])
        {
            return ((UINavigationController *)tabBarSelectVC).viewControllers.lastObject;
        }
        return tabBarSelectVC;
    }
    else if ([superVC isKindOfClass:[UINavigationController class]])
    {
        return ((UINavigationController *)superVC).viewControllers.lastObject;
    }
    else
    {
        return superVC;
    }
}


@end



@implementation BDProgressHud


+(void)showCustomIcon:(NSString *)iconName Title:(NSString *)title ToView:(UIView *)view
{
    [BDProgressView showBDHudViewWithIcon:iconName Message:title ToView:view];
}
+(void)showSuccess:(NSString *)success ToView:(UIView *)view
{
    [self showCustomIcon:@"hub_success" Title:success ToView:view];
}
+(void)showError:(NSString *)error ToView:(UIView *)view
{
    [self showCustomIcon:@"hud_error" Title:error ToView:view];
}
+(void)showInfo:(NSString *)info ToView:(UIView *)view
{
    [self showCustomIcon:@"hud_info" Title:info ToView:view];
}
+(void)showWarn:(NSString *)warn ToView:(UIView *)view
{
    [self showCustomIcon:@"hub_warn" Title:warn ToView:view];
}


+(void)showAutoMessage:(NSString *)message
{
    [self showAutoMessage:message ToView:nil];
}
+(void)showAutoMessage:(NSString *)message ToView:(UIView *)view
{
    [BDProgressView showBDHudView:message ToView:view];
}
//自定义停留时长
+(void)showIconMessage:(NSString *)message ToView:(UIView *)view RemainTime:(CGFloat)time
{
    [BDProgressView showBDIconHudView:message ToView:view Retime:time];
}
+(void)showMessage:(NSString *)message ToView:(UIView *)view RemainTime:(CGFloat)time
{
    [BDProgressView showBDHudView:message ToView:view Retime:time];
}

+(void)showLoadToView:(UIView *)view
{
    [BDProgressView showBDHudLoadingView:@"加载中..." ToView:view];
}
+(void)hideHudForView:(UIView *)view
{
    [BDProgressView hideMBProgressView:view];
}
+(void)hideHud
{
    [self hideHudForView:nil];
}


@end


