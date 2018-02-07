//
//  UIViewController+BDSemiModal.h
//  BaseDemoCore
//
//  Created by scl on 2017/11/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

/*视图模块弹出*/

#define kSemiModalAnimationDuration 0.2

#import <UIKit/UIKit.h>

@interface UIViewController (BDSemiModal)

@property (nonatomic,strong,setter=bd_setExtPresentingSemiViewController:)UIViewController *bd_extPresentingSemiViewController;
@property (nonatomic,strong,setter=bd_setSemiContainerView:)UIView *bd_SemiContainerView;

-(void)bd_presentSemiViewController:(UIViewController *)vc inView:(UIView *)viewContainerView;
-(void)bd_presentSemiView:(UIView *)vc inView:(UIView *)viewContainerView;
-(void)bd_presentSemiViewController:(UIViewController *)vc;
-(void)bd_presentSemiView:(UIView *)vc;

-(void)bd_dismissSemiModalView;
//如果需要点击背景有回调 请重载返回YES
-(BOOL)bd_dismissSemiViewTapOnBackground;


@end
