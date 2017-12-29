//
//  BDSystemTimeUtil.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDSystemTimeUtil : NSObject

//同步服务器时间并调整
+(void)syncTime;
//重置时间
+(void)resetTime;

//是否同步过服务器时间
+(BOOL)isSyncTime;
//获取时间
+(NSDate *)date;

@end
