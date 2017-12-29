//
//  BDRouter.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

//网络请求方式
typedef NS_ENUM(NSInteger,NetRequestMethodType) {
    
    NetRequestMethodType_Get,
    NetRequestMethodType_Post,
};


@interface BDRouter : NSObject

//基本配置
+(void)setup;

+(NSSet *)AppHosts;
+(NSURL *)baseApiURL;
+(NSURL *)baseWebURL;
+(NSString *)baseMetaphysicsApiURLString;
+(NSString *)baseCausalitySocketURLString;

+(AFHTTPSessionManager *)httpClient;
+(void)setupWithBaseApiURL:(NSURL *)baseURL;

+(void)setupUserAgent;
+(BOOL)isWebURL:(NSURL *)url;
+(BOOL)isTelURL:(NSURL *)url;
+(BOOL)isInternalURL:(NSURL *)url; //是否内部服务器
+(BOOL)isPaymentRequestURL:(NSURL *)url;
+(BOOL)isProductionPaymentRequestURL:(NSURL *)url;

+(NSURLRequest *)requestForURL:(NSURL *)url;
+(NSString *)userAgent;

/*专属业务*/
#pragma mark-Auth
+(void)setAuthToken:(NSString *)token;
+(NSURLRequest *)authTokenRequestWithName:(NSString *)userName password:(NSString *)password;

#pragma mark-App
+(NSURLRequest *)appTokenRequest;

#pragma mark-Login/Register
+(NSURLRequest *)createUserRequestWithName:(NSString *)name email:(NSString *)email password:(NSString *)password;









@end
