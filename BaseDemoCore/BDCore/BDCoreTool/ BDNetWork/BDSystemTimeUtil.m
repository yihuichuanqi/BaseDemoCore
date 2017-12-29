//
//  BDSystemTimeUtil.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDSystemTimeUtil.h"
#import "BDRequestAPI.h"

//默认静态时间变量（时间差）
static NSTimeInterval BDSystemTimeInterval=NSTimeIntervalSince1970;

@implementation BDSystemTimeUtil

+(void)syncTime
{
    
}
+(void)resetTime
{
    @synchronized(self){
        BDSystemTimeInterval=NSTimeIntervalSince1970;
    }
}
+(BOOL)isSyncTime
{
    return BDSystemTimeInterval!=NSTimeIntervalSince1970;
}
+(NSDate *)date
{
    @synchronized(self){
        
        NSDate *now=[NSDate date];
        //如果调整过，则当前时间修改时间差
        return BDSystemTimeUtil.isSyncTime?[now dateByAddingTimeInterval:-BDSystemTimeInterval]:now;
    }
}





@end
