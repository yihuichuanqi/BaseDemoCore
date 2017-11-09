//
//  XAspect-JPushAppDelegate.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XAspect/XAspect.h>
#import "BDAppDelegate.h"
#import "BDJPushConfigManager.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif


#define AtAspect JPushAppDelegate
#define AtAspectOfClass BDAppDelegate

@classPatchField(BDAppDelegate)

@synthesizeNucleusPatch(Default,-,BOOL,application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions);
@synthesizeNucleusPatch(Default,-,void,application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken);
@synthesizeNucleusPatch(Default,-,void,application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error);
@synthesizeNucleusPatch(Default,-,void,application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings);
@synthesizeNucleusPatch(Default,-,void,application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler);
@synthesizeNucleusPatch(Default,-,void,dealloc);


AspectPatch(-, BOOL, application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions)
{
    NSLog(@"加载极光推送");
    
    [self initLoadJPush:launchOptions];
    
    return XAMessageForward(application:application didFinishLaunchingWithOptions:launchOptions);
    
}
//远程注册成功委托
AspectPatch(-, void, application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken)
{
    NSString *token=[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token=[token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return XAMessageForward(application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken);
}
AspectPatch(-, void, application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error)
{
    return XAMessageForward(application:application didFailToRegisterForRemoteNotificationsWithError:error);
}

//用户通知（推送）回调 iOS8以上
AspectPatch(-, void,application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings)
{
    //注册远程通知（推送）
    [application registerForRemoteNotifications];
    return XAMessageForward(application:application didRegisterUserNotificationSettings:notificationSettings);
}
AspectPatch(-, void, application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler)
{
    //处理BadgeNumber -1
    [self handlePushMessage:userInfo notification:nil];
    //还要处理走苹果的信息处理
    if (userInfo)
    {
        NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:@"",@"payload", nil];
        [self receiveRemoteMessageHandler:dic];
    }
    completionHandler(UIBackgroundFetchResultNewData);
    return XAMessageForward(application:application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void(^)(UIBackgroundFetchResult result))completionHandler);
}
//ios 10 点击通知进入app触发
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

#endif

AspectPatch(-, void, dealloc)
{
    XAMessageForwardDirectly(dealloc);
}

-(void)initLoadJPush:(NSDictionary *)launchOptions
{
    //配置极光
    //注册APNS
    [self registerUserNotification];
    //处理远程通知启动APP
    [self receiveNotificationByLaunchingOptions:launchOptions];
    
}
#pragma mark-用户通知（推送）自定义方法
-(void)registerUserNotification
{
    /*
     警告：Xcode8的需要手动开启“TARGETS -> Capabilities -> Push Notifications”
     */
    if([[UIDevice currentDevice].systemName floatValue]>=10.0)
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用

#else // Xcode 7编译会调用

#endif
    }
    else
    {
        
    }
    
}

-(void)receiveNotificationByLaunchingOptions:(NSDictionary *)launchOptions
{
    if(launchOptions)
    {
        return;
    }

    //通过远程推送被启动
    NSDictionary *userInfo=[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo)
    {
        
    }
}
    
    

-(void)handlePushMessage:(NSDictionary *)dict notification:(UILocalNotification *)localNotification
{
    if([UIApplication sharedApplication].applicationIconBadgeNumber!=0)
    {
        if(localNotification)
        {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber-=1;
    }
    else
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    }
}
-(void)receiveRemoteMessageHandler:(NSDictionary *)dic
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

    SEL receiveRemoteNotificationSelctor=@selector(receiveRemoteNotification:);
    if([self respondsToSelector:@selector(receiveRemoteNotificationSelctor)])
    {
        [self performSelector:receiveRemoteNotificationSelctor withObject:dic];
    }
    
#pragma clang diagnostic pop

}


@end


#undef AtAspectOfClass
#undef AtAspect

