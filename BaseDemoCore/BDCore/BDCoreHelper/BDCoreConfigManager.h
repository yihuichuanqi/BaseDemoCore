//
//  BDCoreConfigManager.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/6.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BDCoreConfigManagerInstance [BDCoreConfigManager sharedInstance]

@interface BDCoreConfigManager : NSObject

+(BDCoreConfigManager *)sharedInstance;

//是否开启日志
@property (nonatomic,assign,getter=isRecordLogger) BOOL recordLogger;
//是否开启调试插件
@property (nonatomic,assign,getter=isOpenDebug) BOOL openDebug;
//设置JSPatch数组，有值则会启动热更新服务
@property (nonatomic,strong) NSMutableArray *jsPatchMutableArray;


@end
