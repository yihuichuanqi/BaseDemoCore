//
//  UIViewController+BDSemiModal.m
//  BaseDemoCore
//
//  Created by scl on 2017/11/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "UIViewController+BDSemiModal.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

static char kEx_Object_BD;
@interface NSObject (BD)

@property NSObject *bd_exObject;
@end

@implementation NSObject (BD)
-(void)setBd_exObject:(NSObject *)bd_exObject
{
    objc_setAssociatedObject(self, &kEx_Object_BD, bd_exObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSObject *)bd_exObject
{
    return objc_getAssociatedObject(self, &kEx_Object_BD);
}
@end

static char kExtSemiModalView;
static char kExtParentViewController;


@interface UIViewController (BDSemiModalInternal)
@property NSObject *extSemiModalView;
@property NSObject *extParentViewController;

-(UIView *)parentTarget;
@end

@implementation UIViewController (BDSemiModalInternal)

-(void)setExtSemiModalView:(NSObject *)extSemiModalView
{
    objc_setAssociatedObject(self, &kExtSemiModalView, extSemiModalView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSObject *)extSemiModalView
{
    return objc_getAssociatedObject(self, &kExtSemiModalView);
}

-(NSObject *)extParentViewController
{
    return objc_getAssociatedObject(self, &kExtParentViewController);
}
-(void)setExtParentViewController:(NSObject *)extParentViewController
{
    objc_setAssociatedObject(self, &kExtParentViewController, extParentViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}
-(UIViewController *)bd_parentViewControllerForClass:(Class)aClass
{
    if (aClass==nil)
    {
        if (self.parentViewController==nil)
        {
            return self;
        }
    }
    else
    {
        if ([self isKindOfClass:aClass])
        {
            return self;
        }
    }
    return [self.parentViewController bd_parentViewControllerForClass:aClass];
}
-(UIView *)parentTarget
{
    UIViewController *target=[self bd_parentViewControllerForClass:[UITabBarController class]];
    if (target==nil)
    {
        target=[self bd_parentViewControllerForClass:[UINavigationController class]];
    }
    if (target==nil)
    {
        target=[self bd_parentViewControllerForClass:nil];
    }
    return target.view;
}
@end

@implementation UIViewController (BDSemiModal)

-(void)bd_setExtPresentingSemiViewController:(UIViewController *)bd_extPresentingSemiViewController
{
    objc_setAssociatedObject(self, @selector(bd_extPresentingSemiViewController),bd_extPresentingSemiViewController , OBJC_ASSOCIATION_RETAIN);
}
-(UIViewController *)bd_extPresentingSemiViewController
{
    return objc_getAssociatedObject(self, _cmd);
}
-(void)bd_setSemiContainerView:(UIView *)bd_SemiContainerView
{
    objc_setAssociatedObject(self, @selector(bd_SemiContainerView), bd_SemiContainerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIView *)bd_SemiContainerView
{
    return objc_getAssociatedObject(self, _cmd);
}
-(void)bd_presentSemiViewController:(UIViewController *)vc inView:(UIView *)viewContainerView
{
    self.extParentViewController=vc;
    vc.bd_extPresentingSemiViewController=self;
    [self bd_presentSemiView:vc.view inView:viewContainerView];
    
}

-(void)bd_presentSemiViewController:(UIViewController *)vc
{
    self.extParentViewController=vc;
    vc.bd_extPresentingSemiViewController=self;
    [self bd_presentSemiView:vc.view];
}

-(void)bd_presentSemiView:(UIView *)vc inView:(UIView *)viewContainerView
{
    UIView *target=viewContainerView;
    self.bd_SemiContainerView=viewContainerView;
    if (![target.subviews containsObject:vc])
    {
        //计算frame
        CGRect sf=vc.frame;
        CGRect vf=target.frame; //较大图层
        CGRect f=CGRectMake(0, vf.size.height-sf.size.height, vf.size.width, sf.size.height);
        CGRect of=CGRectMake(0, 0, vf.size.width, vf.size.height-sf.size.height);
        
        //透明蒙层
        UIView *overlay=[[UIView alloc]initWithFrame:target.bounds];
        overlay.backgroundColor=[UIColor blackColor];
        overlay.alpha=0.01f;
        [target addSubview:overlay];
        
        //点击其他界面消失
        UIButton *dismissBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [dismissBtn addTarget:self action:@selector(clickonBackground) forControlEvents:UIControlEventTouchUpInside];
        dismissBtn.backgroundColor=[UIColor clearColor];
        dismissBtn.frame=of;
        [overlay addSubview:dismissBtn];
        
        //蒙层动画
        [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
           
            overlay.alpha=0.5;
        }];
        self.extSemiModalView=overlay;
        
        //弹出界面
        vc.frame=CGRectMake(0, vf.size.height, vf.size.width, sf.size.height);
        [target addSubview:vc];
        [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
           
            vc.frame=f;
        }];
        self.bd_exObject=vc;
    }
    
}
-(void)bd_presentSemiView:(UIView *)vc
{
    [self bd_presentSemiView:vc inView:[self parentTarget]];
}
-(void)clickonBackground
{
    SEL sel=@selector(bd_dismissSemiViewTapOnBackground);
    if (self.extParentViewController&&[self.extParentViewController respondsToSelector:sel])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (![self.extParentViewController performSelector:sel])
        {
            [self bd_dismissSemiModalView];
        }
        
#pragma clang diagnostic pop

    }
    else
    {
        [self bd_dismissSemiModalView];
    }
}
-(void)bd_dismissSemiModalView
{
    UIView *target=self.bd_SemiContainerView?:[self parentTarget];
    UIView *modal=[target.subviews objectAtIndex:target.subviews.count-1];
    UIView *overlay=[target.subviews objectAtIndex:target.subviews.count-2];
    [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
       
        modal.frame=CGRectMake(0, target.frame.size.height, modal.frame.size.width, modal.frame.size.height);
        if (![overlay isKindOfClass:[UITabBar class]])
        {
            overlay.alpha=0.f;
        }
    }completion:^(BOOL finished) {
        if (![overlay isKindOfClass:[UITabBar class]])
        {
            [overlay removeFromSuperview];
        }
        if (![modal isKindOfClass:[UITabBar class]])
        {
            [modal removeFromSuperview];
        }
        if ([self.bd_exObject isKindOfClass:[UIView class]])
        {
            [(UIView *)self.bd_exObject removeFromSuperview];
            self.bd_exObject=nil;
        }
        if ([self.extSemiModalView isKindOfClass:[UIView class]])
        {
            [(UIView *)self.extSemiModalView removeFromSuperview];
            self.extSemiModalView=nil;
        }
        self.extParentViewController=nil;
    }];
}
-(BOOL)bd_dismissSemiViewTapOnBackground
{
    return NO;
}


@end
