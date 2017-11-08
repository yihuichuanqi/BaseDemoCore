//
//  BDAnalyticsHelper.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDAnalyticsHelper.h"
#import <Aspects/Aspects.h>
#import "BDAnalyticsConfigManager.h"

@implementation BDAnalyticsHelper

+(void)BDAnalyticsViewController
{
    __weak typeof(self) weakSelf=self;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        [UIViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info, BOOL animated){
            
            UIViewController *controller=[info instance];
            BOOL filterResult=[weakSelf filterWithControllerName:NSStringFromClass([controller class])];
            if (filterResult)
            {
                [weakSelf beginLogPageView:[controller class]];
            }
        } error:NULL];
        
        [UIViewController aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo>info,BOOL animated){
            
            UIViewController *controller=[info instance];
            BOOL fiterResult=[weakSelf filterWithControllerName:NSStringFromClass([controller class])];
            if (fiterResult)
            {
                [weakSelf endLogPageView:[controller class]];
            }
            
        } error:NULL];
        
    });
}

+(void)beginLogPageView:(__unsafe_unretained Class)pageView
{
    return;
}
+(void)endLogPageView:(__unsafe_unretained Class)pageView
{
    return;
}
+(void)beginLogPageViewWithName:(NSString *)pageViewName
{
    return;
}
+(void)endLogPageViewWithName:(NSString *)pageViewName
{
    return;
}


+(void)logEvent:(NSString *)eventId
{
    
}
+(void)logEvent:(NSString *)eventId attributes:(NSDictionary *)attributes
{
    
}



#pragma mark-自定义代码区
//页面筛选
+(BOOL)filterWithControllerName:(NSString *)controllerName
{
    BOOL result=NO;
    if (BDAnalyticsConfigManagerInstance.prefixFilterArray.count==0&&BDAnalyticsConfigManagerInstance.noFilterNameArray.count==0&&BDAnalyticsConfigManagerInstance.filterNameArray.count==0)
    {
        return YES;
    }
    //判断是否符合前缀
    NSArray *prefixArray=BDAnalyticsConfigManagerInstance.prefixFilterArray;
    if (prefixArray)
    {
        for (NSString *prefixItem in prefixArray)
        {
            if ([controllerName hasPrefix:prefixItem])
            {
                result=YES;
                break;
            }
        }
    }
    //若有符合前缀则执行以下判断 是否有被省略掉的页面
    if (result)
    {
        NSArray *noFilterArray=BDAnalyticsConfigManagerInstance.noFilterNameArray;
        if (noFilterArray&&[noFilterArray containsObject:controllerName])
        {
            result=NO;
        }
    }
    else
    {
        NSArray *filterArray=BDAnalyticsConfigManagerInstance.filterNameArray;
        if (filterArray&&[filterArray containsObject:controllerName])
        {
            result=YES;
        }
    }
    return result;
}







@end
