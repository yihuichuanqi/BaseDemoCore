//
//  BDOptions.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

//基本配置
extern NSString *const BDOptionsLoadingScreenAlpha;
extern NSString *const BDOptionsUseVCR;
extern NSString *const BDOptionsSettingMenu;
extern NSString *const BDOptionsDisableNativeLiveAuctions;

@interface BDOptions : NSObject

+(NSArray *)labsOptions;
+(NSArray *)labsOptionsThatRequireRestart;

+(BOOL)boolForOptions:(NSString *)option;
+(void)setValueBool:(BOOL)value forOptions:(NSString *)option;

@end
