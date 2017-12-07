//
//  BDProgressHud.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/13.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface BDProgressHud : NSObject


//自动消失带默认图(3s消失 图片不要太大)
+(void)showSuccess:(NSString *)success ToView:(UIView *)view;
+(void)showError:(NSString *)error ToView:(UIView *)view;
+(void)showInfo:(NSString *)info ToView:(UIView *)view;
+(void)showWarn:(NSString *)warn ToView:(UIView *)view;
+(void)showCustomIcon:(NSString *)iconName Title:(NSString *)title ToView:(UIView *)view;


//文字+苹果默认旋转样式
+(void)showAutoMessage:(NSString *)message;
+(void)showAutoMessage:(NSString *)message ToView:(UIView *)view;

//自定义停留时长
+(void)showIconMessage:(NSString *)message ToView:(UIView *)view RemainTime:(CGFloat)time;
+(void)showMessage:(NSString *)message ToView:(UIView *)view RemainTime:(CGFloat)time;

//加载试图
+(void)showLoadToView:(UIView *)view;

//隐藏
+(void)hideHudForView:(UIView *)view;
+(void)hideHud;


@end
