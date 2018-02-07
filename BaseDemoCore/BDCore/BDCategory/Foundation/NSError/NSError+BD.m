//
//  NSError+BD.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/19.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "NSError+BD.h"
#import "NSDictionary+BD.h"

const NSInteger BDRevCodeAccountExpird=2;
const NSInteger BDRevCodeNotExist=500;
const NSInteger BDRevCodeCollectSpotCheckStatusChanged=601;
const NSInteger BDRevCodeSpotDeleted=300000;

const NSInteger BDRevCodePayFailure=600000; //支付失败 实际上没有发生支付 需重试
const NSInteger BDRevCodePayException=600001;//支付异常 支付发生但没成功 需人工介入
const NSInteger BDRevCodeRefundFailure=600002;//退款失败 实际没有发生退款 需重试
const NSInteger BDRevCodeRefundException=600003;//退款异常 退款发生但没成功 需人工介入
const NSInteger BDRevCodeRefundNotPayed=600004;//有未支付订单
const NSInteger BDRevCodeRefundCharging=600005;//有充电中订单
const NSInteger BDRevCodeRefundOddOrder=600006;//有异常订单

const NSInteger BDRevCodeStartChargingFailByRefunding=400002;
const NSInteger BDRevCodeStartChargingFailByNotPayDeposit=400003;

#define kError_UserInfo @"userInfo"


@implementation NSError (BD)


+(NSError *)bd_Error:(NSString *)errorMsg
{
    return [NSError bd_Error:errorMsg revCode:kBDError_Code];
}
+(NSError *)bd_Error:(NSString *)errorMsg revCode:(NSInteger)code
{
    NSString *appDomain=@"主机名";
    if(!errorMsg.length)
    {
        return [NSError errorWithDomain:appDomain code:kBDError_Code+code userInfo:@{kError_UserInfo:@"未知错误"}];
    }
    return [NSError errorWithDomain:appDomain code:kBDError_Code+code userInfo:@{kError_UserInfo:errorMsg}];
}
+(NSError *)bd_ErrorWithResponse:(NSDictionary *)responseDic
{
    if([responseDic bd_ErrorCode]==0)
    {
        return nil;
    }
    if([responseDic isKindOfClass:[NSDictionary class]])
    {
        return [self bd_Error:[responseDic bd_ErrorMessage] revCode:[responseDic bd_ErrorCode]];
    }
    return [self bd_Error:nil];
}
//网络状态
+(NSError *)bd_ErrorForNetWork
{
    NSString *appDomain=@"主机名";
    return [NSError errorWithDomain:appDomain code:kCFURLErrorNotConnectedToInternet userInfo:nil];
}

-(NSInteger)bd_RevCode
{
    return self.code - kBDError_Code;
}
-(NSString *)bd_ErrorMsg
{
    NSString *message=[self.userInfo bd_StringObjectForKey:kError_UserInfo];
    if (message.length)
    {
        return message;
    }
    switch (self.code) {
        case kCFURLErrorNotConnectedToInternet:
        case kCFURLErrorCannotConnectToHost:
        case kCFURLErrorNetworkConnectionLost:
        case kCFURLErrorCannotFindHost:
            message=@"网络不可用，请检查";
            break;
        case NSURLErrorTimedOut:
            message=@"通信超时，请检查网络是否正常";
            break;
        default:
            message=@"网络通信错误";
            break;
    }
    return message;
}
-(BOOL)isBDError
{
    if (self.code>=kBDError_Code)
    {
        return YES;
    }
    return NO;
}
-(BOOL)isNetworkError
{
    return self.code==kCFURLErrorCannotFindHost||
            self.code==kCFURLErrorCannotConnectToHost||
            self.code==kCFURLErrorNetworkConnectionLost||
            self.code==kCFURLErrorNotConnectedToInternet||
            self.code==NSURLErrorTimedOut;
}

/*
 //错误类型
switch (code) {
    case NSURLErrorBadURL:
        errorMsg = @"网络路径错误";
        break;
    case NSURLErrorTimedOut:
        errorMsg = @"网络超时";
        break;
    case NSURLErrorCannotFindHost:
        errorMsg = @"网络服务器不存在";
        break;
    case NSURLErrorCannotConnectToHost:
        errorMsg = @"网络无法连接到服务器";
        break;
    case NSURLErrorNetworkConnectionLost:
        errorMsg = @"网络连接消失了";
        break;
    case NSURLErrorDNSLookupFailed:
        errorMsg = @"网络DNS域名解析失败";
        break;
    case NSURLErrorHTTPTooManyRedirects:
        errorMsg = @"网络重定向太多，HTTP连接失败";
        break;
    case NSURLErrorNotConnectedToInternet:
        errorMsg = @"网络设备似乎没有连接到互联网";
        break;
    case NSURLErrorRedirectToNonExistentLocation:
        errorMsg = @"网络连接失败，被重定向到一个不存在的位置";
        break;
    case NSURLErrorBadServerResponse:
        errorMsg = @"网络连接失败，收到无效的服务器响应";
        break;
    case NSURLErrorUserCancelledAuthentication:
        errorMsg = @"网络连接失败，用户取消了所需认证";
        break;
    case NSURLErrorUserAuthenticationRequired:
        errorMsg = @"网络连接失败，用户没有授权所需认证";
        break;
    case NSURLErrorZeroByteResource:
        errorMsg = @"网络连接检索的资源是零字节";
        break;
    case NSURLErrorCannotDecodeRawData:
        errorMsg = @"无法解码返回数据（编码类型已知）";
        break;
    case NSURLErrorCannotDecodeContentData:
        errorMsg = @"无法解码返回数据（编码类型未知）";
        break;
    case NSURLErrorCannotParseResponse:
        errorMsg = @"无法解析返回数据";
        break;
    case NSURLErrorFileDoesNotExist:
        errorMsg = @"文件操作失败，因为该文件不存在";
        break;
    case NSURLErrorFileIsDirectory:
        errorMsg = @"文件操作失败，因为该文件是文件夹";
        break;
    case NSURLErrorNoPermissionsToReadFile:
        errorMsg = @"文件操作失败，因为它没有读取文件的权限";
        break;
    case NSURLErrorDataLengthExceedsMaximum:
        errorMsg = @"文件操作失败，因为该文件太大";
        break;
    default:
        errorMsg = nil;
        break;
 
 */



@end
