//
//  BDAppStatus.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/22.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDAppStatus.h"
#import "BDUser.h"
#import "BDAppConst.h"
@implementation BDAppStatus

+(BOOL)isDev
{
#if TARGET_IPHONE_SIMULATOR
    return YES;
#elif DEBUG
    return YES;
#else
    return NO;
#endif

}

+(BOOL)isBeta
{
    static BOOL isBeta=NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (floor(NSFoundationVersionNumber)<=NSFoundationVersionNumber10_6_1)
        {
            //ios6或之前需调用其他方法
        }
        else
        {
            NSURL *receipURL=[[NSBundle mainBundle] appStoreReceiptURL];
            NSString *receiptURLString=[receipURL path];
            isBeta=[receiptURLString rangeOfString:@"sandboxReceipt"].location!=NSNotFound;
        }
        
    });
    return isBeta;
}
+(BOOL)isBetaOrDev
{
    return [self isDev]||[self isBeta];
}
+(BOOL)isBetaDevOrAdmin
{
    if ([self isBetaOrDev])
    {
        return YES;
    }
    NSString *email=[BDUser currentUser].email;
    BOOL isAppEmail=[email hasSuffix:@""]||[email hasSuffix:@""];
    return isAppEmail;
}

+(BOOL)isDemo
{
    return BDIsRunningInDemoMode;
}

+(BOOL)isRunningTests
{
    static BOOL isRunningTests=NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isRunningTests=NSClassFromString(@"XCTestCase")!=NULL;
    });
    return isRunningTests;
}







@end
