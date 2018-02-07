//
//  NSError+BD.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/19.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCFURLErrorFrameLoadInterrupted (102)
//默认错误Code
#define kBDError_Code (999999)

//各种错误值
extern const NSInteger BDRevCodeAccountExpird;
extern const NSInteger BDRevCodeNotExist;
extern const NSInteger BDRevCodeCollectSpotCheckStatusChanged;
extern const NSInteger BDRevCodeSpotDeleted;

extern const NSInteger BDRevCodePayFailure; //支付失败 实际上没有发生支付 需重试
extern const NSInteger BDRevCodePayException;//支付异常 支付发生但没成功 需人工介入
extern const NSInteger BDRevCodeRefundFailure;//退款失败 实际没有发生退款 需重试
extern const NSInteger BDRevCodeRefundException;//退款异常 退款发生但没成功 需人工介入
extern const NSInteger BDRevCodeRefundNotPayed;//有未支付订单
extern const NSInteger BDRevCodeRefundCharging;//有充电中订单
extern const NSInteger BDRevCodeRefundOddOrder;//有异常订单

extern const NSInteger BDRevCodeStartChargingFailByRefunding;//开启充电失败 用户保证金退款中
extern const NSInteger BDRevCodeStartChargingFailByNotPayDeposit;//开启充电失败 用户没有缴纳保证金


@interface NSError (BD)

@property (nonatomic,readonly) NSInteger bd_RevCode;
@property (nonatomic,readonly) NSString *bd_ErrorMsg;

//构造
+(NSError *)bd_Error:(NSString *)errorMsg;
+(NSError *)bd_Error:(NSString *)errorMsg revCode:(NSInteger)code;
+(NSError *)bd_ErrorWithResponse:(NSDictionary *)responseDic;
//网络状态
+(NSError *)bd_ErrorForNetWork;

//判断错误类型
-(BOOL)isBDError;
-(BOOL)isNetworkError;


@end
