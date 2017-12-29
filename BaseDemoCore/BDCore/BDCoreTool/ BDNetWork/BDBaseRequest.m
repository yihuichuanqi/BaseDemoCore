//
//  BDBaseRequest.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDBaseRequest.h"
#import "BDFunctionConst.h"

NSString *const BD_BaseRequest_StatusCodeKey=@"bd_code";
NSString *const BD_BaseRequest_DataValueKey=@"0000";
NSString *const BD_BaseRequest_StatusMsgKey=@"bd_msg";
NSString *const BD_BaseRequest_DataKey=@"bd_data";



@implementation BDBaseRequest

#pragma mark-override YTKBaseRequest 方法
-(YTKRequestMethod)requestMethod
{
    return YTKRequestMethodPOST;
}
-(YTKRequestSerializerType)requestSerializerType
{
    return YTKRequestSerializerTypeHTTP;
}
-(YTKResponseSerializerType)responseSerializerType
{
    return YTKResponseSerializerTypeJSON;
}
-(id)requestArgument
{
    return @{};
}
-(NSTimeInterval)requestTimeoutInterval
{
    return 30.f;
}
-(void)start
{
    [super start];
}
-(void)stop
{
    [super stop];
}

//重定义错误error

-(NSError *)error
{
    NSError *error= [super error];
    NSDictionary *responseDict=[super responseJSONObject];

    //获取服务器反馈
    NSString *strCode=DecodeStringFromDic(responseDict, BD_BaseRequest_StatusCodeKey);
    NSString *strMessage=DecodeStringFromDic(responseDict, BD_BaseRequest_StatusMsgKey);
    //获取原有Domain
    NSErrorDomain domain=error.domain;
    NSInteger errorCode=error.code;
    NSMutableDictionary *userInfo=[NSMutableDictionary dictionaryWithDictionary:error.userInfo];
    if ([strCode integerValue]==-999)
    {
        [userInfo setValue:strMessage forKey:NSLocalizedDescriptionKey];
        error=[NSError errorWithDomain:domain code:errorCode userInfo:[userInfo copy]];
    }
    return error;
}

//json解析
-(id)responseJSONObject
{
    NSDictionary *dict=[super responseJSONObject];
    id data=[dict objectForKey:@"data"];
    if (self.reformDelegate&&[self.reformDelegate respondsToSelector:@selector(bdRequest:reformJsonResponse:)])
    {
        return [_reformDelegate bdRequest:self reformJsonResponse:data];
    }
    return [self responseJSONObject];
}
//验证状态码
-(BOOL)statusCodeValidator
{
    NSDictionary *responseDict=[super responseJSONObject];
    //验证服务端返回码
    NSString *strCode=DecodeStringFromDic(responseDict, BD_BaseRequest_StatusCodeKey);
    if ([strCode isEqualToString:BD_BaseRequest_DataValueKey])
    {
        return YES;
    }
    return NO;
}

#pragma mark-override
-(id)bd_reformJsonResponse:(id)jsonResponse
{
    return jsonResponse;
}
-(id)bd_extraRequestArgument
{
    return nil;
}









@end
