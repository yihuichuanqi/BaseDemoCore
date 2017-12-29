//
//  BDOptions.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDOptions.h"

NSString *const BDOptionsLoadingScreenAlpha=@"Loading Screens Are Transparent";
NSString *const BDOptionsUseVCR=@"Use OffLine Recording";
NSString *const BDOptionsSettingMenu=@"Enable User Settings";
NSString *const BDOptionsDisableNativeLiveAuctions=@"Disable Native Live Auctions";



@implementation BDOptions

+(NSArray *)labsOptions
{
    return @[
             BDOptionsUseVCR,
             BDOptionsSettingMenu,
             ];
}
+(NSArray *)labsOptionsThatRequireRestart
{
    return @[
             BDOptionsDisableNativeLiveAuctions,
             ];
}
+(BOOL)boolForOptions:(NSString *)option
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:option];
}
+(void)setValueBool:(BOOL)value forOptions:(NSString *)option
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:option];
    [[NSUserDefaults standardUserDefaults] synchronize];
}













@end
