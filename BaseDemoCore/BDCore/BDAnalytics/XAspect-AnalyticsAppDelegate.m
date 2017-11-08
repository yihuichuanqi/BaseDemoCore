//
//  XAspect-AnalyticsAppDelegate.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XAspect/XAspect.h>
#import "BDAnalyticsConfigManager.h"
#import "BDAppDelegate.h"

#define AtAspect AnalyticsAppDelegate
#define AtAspectOfClass BDAppDelegate

@classPatchField(BDAppDelegate)

AspectPatch(-, BOOL, application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions)
{
    NSLog(@"加载统计");
    
    if(BDAnalyticsConfigManagerInstance.isLogEnabled)
    {
        
    }
    return XAMessageForward(application:application didFinishLaunchingWithOptions:launchOptions);
    
}

@end

#undef AtAspectOfClass
#undef AtAspect
