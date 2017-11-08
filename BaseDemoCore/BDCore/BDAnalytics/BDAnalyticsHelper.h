//
//  BDAnalyticsHelper.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDAnalyticsHelper : NSObject

//统计进入与离开视图
+(void)BDAnalyticsViewController;

//在viewWillAppear几viewDidDisppeary调用 才能正确获取页面访问路径 访问深度数据
+(void)beginLogPageView:(__unsafe_unretained Class) pageView;
+(void)endLogPageView:(__unsafe_unretained Class) pageView;
//自定义名称
+(void)beginLogPageViewWithName:(NSString *)pageViewName;
+(void)endLogPageViewWithName:(NSString *)pageViewName;

//自定义事件
+(void)logEvent:(NSString *)eventId;
+(void)logEvent:(NSString *)eventId attributes:(NSDictionary *)attributes;





@end
