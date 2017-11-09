//
//  BDAlertView.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/9.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const BDAlertViewWillShowNotification;
UIKIT_EXTERN NSString *const BDAlertViewDidShowNotification;
UIKIT_EXTERN NSString *const BDAlertViewWillDismissNotification;
UIKIT_EXTERN NSString *const BDAlertViewDidDismissNotification;

typedef void (^ClickHandler)(void);
typedef void (^ClickHandlerWithIndex)(NSInteger index);

typedef NS_ENUM(NSInteger,BDAlertViewButtonType) {
    
    BDAlertViewButtonType_Default=0,
    BDAlertViewButtonType_Cancel,
    BDAlertViewButtonType_Warn,
    BDAlertViewButtonType_None,
    BDAlertViewButtonType_Height,
    
    
};


@interface BDAlertView : UIView


+(void)showOneButtonWithTitle:(NSString *)title Message:(NSString *)message ButtonType:(BDAlertViewButtonType)buttonType ButtonTitle:(NSString *)buttonTitle ClickHandler:(ClickHandler)handler;
+(void)showTwoButtonWithTitle:(NSString *)title Message:(NSString *)message ButtonType:(BDAlertViewButtonType)buttonType ButtonTitle:(NSString *)buttonTitle ClickHandler:(ClickHandler)handler ButtonType:(BDAlertViewButtonType)buttonType ButtonTitle:(NSString *)buttonTitle ClickHandler:(ClickHandler)handler;
+(void)showMultipleButtonsWithTitle:(NSString *)title Message:(NSString *)message ClickHandler:(ClickHandlerWithIndex)handler Buttons:(NSDictionary *)buttons,... NS_REQUIRES_NIL_TERMINATION ;

//自定义视图
-(instancetype)initWithCustomView:(UIView *)customView DismissWhenTouchedBackground:(BOOL)dismissWhenTouchBackground;
-(void)configAlertViewPropertyWithTitle:(NSString *)title Message:(NSString *)message Buttons:(NSArray *)buttons Clicks:(NSArray *)clicks ClickWithIndex:(ClickHandlerWithIndex)clickIndex;
-(void)show;
-(void)dismissWithCompletion:(void(^)(void))completion;






@end
