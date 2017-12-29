//
//  BDRequestAPI.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

/*
 *其他模块功能 可扩展此类
 */
//服务器成功回调Block
typedef void(^ResponseSuccessBlock)(id dataObj);
//服务器错误回调Block
typedef void(^ResponseErrorBlock)(NSError *error);
typedef void(^ResponseErrorCodeMessageBlock)(NSString *msg,NSString *code);


#import <Foundation/Foundation.h>

@interface BDRequestAPI : NSObject

//获取暂时的AppToken
+(void)getAppTokenWithCompletion:(void(^)(NSString *appToken,NSDate *expirationDate))callBack;
+(void)getAppTokenWithCompletion:(void(^)(NSString *appToken,NSDate *expirationDate))callBack failure:(void(^)(NSError *error))failureBlock;



@end
