//
//  XAspect-ShareAppDelegate.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XAspect/XAspect.h>
#import "BDShareConfigManager.h"
#import "BDAppDelegate.h"

#define AtAspect ShareAppDelegate
#define AtAspectOfClass BDAppDelegate

@classPatchField(BDAppDelegate)

AspectPatch(-, BOOL, application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions)
{
    NSLog(@"加载分享");
    if(BDShareConfigManagerInstance.isLogEnabled)
    {
        
    }
    if(BDShareConfigManagerInstance.shareAppKey)
    {
        
    }
    //各平台
   //新浪
    if(BDShareConfigManagerInstance.bdSocialConfig_Sine_AppKey&&BDShareConfigManagerInstance.bdSocialConfig_Sine_AppSecrect&&BDShareConfigManagerInstance.bdSocialConfig_Sine_RedirectUrl)
    {
        NSLog(@"新浪平台设置");
    }
    return XAMessageForward(application:application didFinishLaunchingWithOptions:launchOptions);
}



@end
#undef AtAspectOfClass
#undef AtAspect





