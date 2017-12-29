//
//  BDSystemTimeModel.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDSystemTimeModel.h"

@interface BDSystemTimeModel ()

@property (nonatomic,strong,readonly) NSString *time;

@property (nonatomic,assign,readonly) NSInteger wday;
//年月日
@property (nonatomic,assign,readonly) NSInteger year;
@property (nonatomic,assign,readonly) NSInteger month;
@property (nonatomic,assign,readonly) NSInteger day;
//时分秒
@property (nonatomic,assign,readonly) NSInteger hour;
@property (nonatomic,assign,readonly) NSInteger min;
@property (nonatomic,assign,readonly) NSInteger sec;

@property (nonatomic,assign,readonly) BOOL dst;
@property (nonatomic,assign,readonly) NSInteger unix;
@property (nonatomic,assign,readonly) float utcOffset;

@property (nonatomic,strong,readonly) NSString *zome;
@property (nonatomic,strong,readonly) NSString *iso8601;


@end


@implementation BDSystemTimeModel

-(NSDate *)date
{
    ISO8601DateFormatter *dateFormatter=[[ISO8601DateFormatter alloc]init];
    return [dateFormatter dateFromString:self.iso8601];
}

-(NSTimeInterval)timeIntervalSinceDate:(NSDate *)date
{
    return [self.date timeIntervalSinceDate:date];
}


@end
