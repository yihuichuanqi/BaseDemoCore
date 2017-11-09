//
//  MBProgressHUD+BD.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "MBProgressHUD+BD.h"

//#define Chinese_MBProgressHud_System(x) [UIFont fontWithName:@"Heiti SC" size:x]
#define Chinese_MBProgressHud_System(x) [UIFont boldSystemFontOfSize:x]

@implementation MBProgressHUD (BD)

+(void)showCustomIcon:(NSString *)iconName Title:(NSString *)title ToView:(UIView *)view
{
 
    if (view==nil)
    {
        view=(UIView *)[UIApplication sharedApplication].delegate.window;
    }
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text=title;
    hud.label.font=Chinese_MBProgressHud_System(16);
    hud.contentColor=[UIColor whiteColor];
//    UIImage *image=[[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *image=[UIImage imageNamed:iconName];
    hud.customView=[[UIImageView alloc]initWithImage:image];
    hud.mode=MBProgressHUDModeCustomView;
    hud.square=YES;
    hud.removeFromSuperViewOnHide=YES;
    hud.bezelView.style=MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color=[UIColor colorWithWhite:0.f alpha:0.8f];
    //是否需要蒙版效果
//    hud.backgroundView.style=MBProgressHUDBackgroundStyleSolidColor;
//    hud.backgroundView.color=[UIColor colorWithWhite:0.f alpha:0.6f];
    //2s消失
    [hud hideAnimated:YES afterDelay:2];
}

+(void)showSuccess:(NSString *)success ToView:(UIView *)view
{
    [self showCustomIcon:@"hub_success" Title:success ToView:view];
}
+(void)showError:(NSString *)error ToView:(UIView *)view
{
    [self showCustomIcon:@"hub_warn" Title:error ToView:view];
}
+(void)showInfo:(NSString *)info ToView:(UIView *)view
{
    [self showCustomIcon:@"hub-" Title:info ToView:view];
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
    [self showMessage:message ToView:view RemainTime:2 Model:MBProgressHUDModeText];
}
+(void)showMessage:(NSString *)message ToView:(UIView *)view RemainTime:(CGFloat)timel Model:(MBProgressHUDMode)model
{
    if (view==nil)
    {
        view=(UIView *)[UIApplication sharedApplication].delegate.window;
    }
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text=message;
    hud.mode=model;
    hud.label.font=Chinese_MBProgressHud_System(18);
    hud.contentColor=[UIColor whiteColor];
    hud.removeFromSuperViewOnHide=YES;
    hud.bezelView.style=MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color=[UIColor colorWithWhite:0.f alpha:0.8f];
//    hud.backgroundView.style=MBProgressHUDBackgroundStyleSolidColor;
//    hud.backgroundView.color=[UIColor colorWithWhite:0.f alpha:0.6f];
    [hud hideAnimated:YES afterDelay:timel];
}

+(void)showIconMessage:(NSString *)message ToView:(UIView *)view RemainTime:(CGFloat)time
{
    [self showMessage:message ToView:view RemainTime:time Model:MBProgressHUDModeIndeterminate];
}
+(void)showMessage:(NSString *)message ToView:(UIView *)view RemainTime:(CGFloat)time
{
    [self showMessage:message ToView:view RemainTime:time Model:MBProgressHUDModeText];
}


+(MBProgressHUD *)showMessage:(NSString *)message ToView:(UIView *)view
{
    if (view==nil)
    {
        view=(UIView *)[UIApplication sharedApplication].delegate.window;
    }
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode=MBProgressHUDModeText;
    hud.label.text=message;
    hud.label.font=Chinese_MBProgressHud_System(18);
    hud.contentColor=[UIColor whiteColor];
    hud.removeFromSuperViewOnHide=YES;
    hud.bezelView.style=MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color=[UIColor colorWithWhite:0.f alpha:0.8f];
//    hud.backgroundView.style=MBProgressHUDBackgroundStyleSolidColor;
//    hud.backgroundView.color=[UIColor colorWithWhite:0.f alpha:0.6f];
    return hud;
}
+(void)showLoadToView:(UIView *)view
{
    [self showMessage:@"加载中..." ToView:view];
}
+(MBProgressHUD *)showProgressToView:(UIView *)view ToText:(NSString *)text
{
    if (view==nil)
    {
        view=(UIView *)[UIApplication sharedApplication].delegate.window;
    }
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text=text;
    hud.label.font=Chinese_MBProgressHud_System(18);
    hud.contentColor=[UIColor whiteColor];
    hud.bezelView.style=MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color=[UIColor colorWithWhite:0.f alpha:0.8f];
//    hud.backgroundView.style=MBProgressHUDBackgroundStyleSolidColor;
//    hud.backgroundView.backgroundColor=[UIColor colorWithWhite:0.f alpha:0.1f];
    return hud;
}

+(void)hideHudForView:(UIView *)view
{
    if (view==nil)
    {
        view=(UIView *)[UIApplication sharedApplication].delegate.window;
    }
    [self hideHUDForView:view animated:YES];
}
+(void)hideHud
{
    [self hideHudForView:nil];
}


@end
