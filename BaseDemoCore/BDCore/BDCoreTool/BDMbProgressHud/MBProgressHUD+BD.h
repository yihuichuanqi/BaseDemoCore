//
//  MBProgressHUD+BD.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (BD)


//自定义图片提示（3s消失 图片不要太大）
+(void)showCustomIcon:(NSString *)iconName Title:(NSString *)title ToView:(UIView *)view;
//自动消失带默认图
+(void)showSuccess:(NSString *)success ToView:(UIView *)view;
+(void)showError:(NSString *)error ToView:(UIView *)view;
+(void)showInfo:(NSString *)info ToView:(UIView *)view;
+(void)showWarn:(NSString *)warn ToView:(UIView *)view;

//文字+苹果默认旋转样式
+(MBProgressHUD *)showMessage:(NSString *)message ToView:(UIView *)view;
+(void)showAutoMessage:(NSString *)message;
+(void)showAutoMessage:(NSString *)message ToView:(UIView *)view;
//自定义停留时长
+(void)showIconMessage:(NSString *)message ToView:(UIView *)view RemainTime:(CGFloat)time;
+(void)showMessage:(NSString *)message ToView:(UIView *)view RemainTime:(CGFloat)time;

//加载试图
+(void)showLoadToView:(UIView *)view;
+(MBProgressHUD *)showProgressToView:(UIView *)view ToText:(NSString *)text;

//隐藏
+(void)hideHudForView:(UIView *)view;
+(void)hideHud;

@end
