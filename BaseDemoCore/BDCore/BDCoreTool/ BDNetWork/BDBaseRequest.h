//
//  BDBaseRequest.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

//服务器返回数据基本key value判断
FOUNDATION_EXTERN NSString *const BD_BaseRequest_StatusCodeKey; //状态码key
FOUNDATION_EXTERN NSString *const BD_BaseRequest_DataValueKey; //成功状态标识value
FOUNDATION_EXTERN NSString *const BD_BaseRequest_StatusMsgKey; //响应信息key
FOUNDATION_EXTERN NSString *const BD_BaseRequest_DataKey; //响应数据key
@class BDBaseRequest;

@protocol BDBaseRequestReformDelegate <NSObject>
//自定义解析器响应参数(返回自定义格式数据)
-(id)bdRequest:(BDBaseRequest *)request reformJsonResponse:(id)jsonResponse;
@end

@interface BDBaseRequest : YTKRequest

//数据重塑代理
@property (nonatomic,weak) id<BDBaseRequestReformDelegate>reformDelegate;

//子类重写方法
-(id)bd_reformJsonResponse:(id)jsonResponse; //自定义解析器
-(id)bd_extraRequestArgument;//额外参数



@end
