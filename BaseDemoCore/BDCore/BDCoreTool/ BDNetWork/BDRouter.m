//
//  BDRouter.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDRouter.h"
#import "BDNetWorkConstants.h"
#import "BDDefaultsConst.h"
#import "BDNotificationConst.h"
#import "BDAppKeys.h"

#import "BDOptions.h"

#import "BDUserManager.h"
#import "BDUser.h"

static NSSet *appHosts=nil;
static AFHTTPSessionManager *staticHttpClient=nil;
//获取网址的服务器名称
static NSString *hostFromString(NSString *string)
{
    NSURL *url=[NSURL URLWithString:string];
    return [[NSURL URLWithString:string] host];
}


@implementation BDRouter

+(void)setup
{
    //生产环境服务地址
    NSString *productionWeb=hostFromString(BDBaseWebURL);
    NSString *productionDeprecatedMobileWeb=hostFromString(BDBaseDeprecatedMobileWebURL);
    NSString *productionAPI=hostFromString(BDBaseApiURL);
    //测试环境地址
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *stagingWeb=hostFromString([defaults stringForKey:BDStagingWebURLDefaults]);
    NSString *stagingDeprecatedMobileWeb=hostFromString([defaults stringForKey:BDStagingDeprecatedMobileWebURLDefaults]);
    NSString *stagingAPI=hostFromString([defaults stringForKey:BDStagingApiURLDefaults]);
    
    NSArray *array=@[
                     @"www.nutfin.com",
                     productionAPI,productionWeb,productionDeprecatedMobileWeb,
                     stagingAPI,stagingWeb,stagingDeprecatedMobileWeb
                     ];
    appHosts=[NSSet setWithArray:array];
    
    [BDRouter setupWithBaseApiURL:[BDRouter baseApiURL]];
    [self setupUserAgent];
}

+(NSSet *)AppHosts
{
    return appHosts;
}

+(NSURL *)baseApiURL
{
    //是否使用测试环境服务地址
    if ([BDOptions boolForOptions:BDUseStagingDefaults])
    {
        NSString *stagingBaseAPI=[[NSUserDefaults standardUserDefaults] stringForKey:BDStagingApiURLDefaults];
        return [NSURL URLWithString:stagingBaseAPI];
    }
    else
    {
        return [NSURL URLWithString:BDBaseApiURL];
    }
}
+(NSURL *)baseWebURL
{
    NSString *stagingBaseWebURL=[[NSUserDefaults standardUserDefaults] stringForKey:BDStagingWebURLDefaults];
    NSString *url=[BDOptions boolForOptions:BDUseStagingDefaults]?stagingBaseWebURL:BDBaseWebURL;
    return [NSURL URLWithString:url];
}
+(NSString *)baseMetaphysicsApiURLString
{
    if ([BDOptions boolForOptions:BDUseStagingDefaults])
    {
        NSString *stagingBaseAPI=[[NSUserDefaults standardUserDefaults] stringForKey:BDStagingMetaphysicsURLDefaults];
        return stagingBaseAPI;
    }
    else
    {
        return BDBaseMetaphysicsApiURL;
    }
}
+(NSString *)baseCausalitySocketURLString
{
    return [self causalitySocketURLStringWithProduction:BDCausalitySocketURL];
}
+(NSString *)causalitySocketURLStringWithProduction:(NSString *)productionURL
{
    if ([BDOptions boolForOptions:BDUseStagingDefaults])
    {
        NSString *stagingSocketURLString=[[NSUserDefaults standardUserDefaults] stringForKey:BDStagingLiveSocketURLDefaults];
        return stagingSocketURLString;
    }
    else
    {
        return productionURL;
    }
}

+(void)setupUserAgent
{
    NSString *userAgent=[self userAgent];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                              @"UserAgent":userAgent
                                                              }];
    [self setHttpHeader:@"User-Agent" value:userAgent];
}

+(void)setupWithBaseApiURL:(NSURL *)baseURL
{
    staticHttpClient=[[AFHTTPSessionManager alloc]initWithBaseURL:baseURL];
    [staticHttpClient.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
       
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                
                break;
            case AFNetworkReachabilityStatusNotReachable:
            {
                NSLog(@"《《网络不可用》》");
            }
                break;
                
            default:
            {
                NSLog(@"《《网络可请求数据》》");
            }
                break;
        }
    }];
    
    UIApplicationState state=[[UIApplication sharedApplication] applicationState];
    BDUserManager *userManager=[BDUserManager sharedManager];
    //确保用户信息不存在并且应用不在后台（可能会后台轮询下载） 则移除通行token
    if (![userManager hasExistingAccount]&&state!=UIApplicationStateBackground)
    {
        [UICKeyChainStore removeItemForKey:BDAuthTokenDefaults];
        [UICKeyChainStore removeItemForKey:BDAppTokenKeyChainKeyDefaults];
    }
    
    NSString *token=[UICKeyChainStore stringForKey:BDAuthTokenDefaults];
    if (token)
    {
        NSLog(@"AuthToken In the keychain!!!");
        [BDRouter setAuthToken:token];
    }
    else
    {
        NSLog(@"Temporary Local AppToken In the keychain!!!");
        NSString *appToken=[UICKeyChainStore stringForKey:BDAppTokenKeyChainKeyDefaults];
        [BDRouter setAppToken:appToken];
    }
    if ([BDUser isLocalTemporaryUser])
    {
        [self setHttpHeader:BDEigenLocalTemporaryUserHeaderKey value:userManager.localTemporaryUserUUID];
    }
}

+(AFHTTPSessionManager *)httpClient
{
    return staticHttpClient;
}
+(BOOL)isWebURL:(NSURL *)url
{
    //isEqual判断两个对象在类型和值上是否一样
    return (!url.scheme||([url.scheme isEqual:@"http"]||[url.scheme isEqual:@"https"]));
}
+(BOOL)isTelURL:(NSURL *)url
{
    return (url.scheme&&[url.scheme isEqual:@"tel"]);
}
+(BOOL)isPaymentRequestURL:(NSURL *)url
{
    return [url.host hasSuffix:@""]||[self isProductionPaymentRequestURL:url];
}
+(BOOL)isProductionPaymentRequestURL:(NSURL *)url
{
    return [url.host hasSuffix:@""];
}
//不允许其他的苹果链接（itms/maps.apple等）
+(BOOL)isInternalURL:(NSURL *)url
{
    //判断是否是applewebdata或者域名
    if ([url.scheme isEqual:@"applewebdata"]||[url.scheme isEqual:@"domain"])
    {
        return YES;
    }
    if (![self isWebURL:url])
    {
        return NO;
    }
    NSString *host=url.host;
    if ([host hasPrefix:@"www"])
    {
        host=[host substringFromIndex:4];
    }
    //Host为空也承认是相关地址
    BOOL isRelative=(host==nil);
    return isRelative||[self isAppDomainHost:host];
}

//判断是否是自己的域名（包括生产、测试、开发等环境）
+(BOOL)isAppDomainHost:(NSString *)host
{
    if (host)
    {
        return ([appHosts containsObject:host]||[host hasSuffix:@".domain.net"]);
    }
    else
    {
        return NO;
    }
}

+(NSString *)userAgent
{
    static NSString *cachedUserAgent;
    if (cachedUserAgent)
    {
        return cachedUserAgent;
    }
    NSString *version=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    //先获取AF默认的 然后添加自定义字段
    AFHTTPRequestSerializer *serializer=[[AFHTTPRequestSerializer alloc]init];
    NSString *userAgent=serializer.HTTPRequestHeaders[@"User-Agent"];
    NSString *agentString=[NSString stringWithFormat:@"Mozilla/5.0 Artsy-Mobile/%@ Eigen/%@",version,build];
    userAgent=[userAgent stringByReplacingOccurrencesOfString:@"Artsy" withString:agentString];
    userAgent=[userAgent stringByAppendingString:@"AppleWebKit/601.1.46 (KHTML, like Gecko)"];
    cachedUserAgent=userAgent;
    return userAgent;
}
+(NSURLRequest *)requestForURL:(NSURL *)url
{
    NSMutableURLRequest *request=[self requestWithMethod:NetRequestMethodType_Get URLString:url.absoluteString parameters:nil];
    //非
    if (![BDRouter isInternalURL:url])
    {
        [request setValue:nil forHTTPHeaderField:BDAuthTokenHeaderKey];
        [request setValue:nil forHTTPHeaderField:BDAppTokenHeaderKey];
        [request setValue:nil forHTTPHeaderField:BDEigenLocalTemporaryUserHeaderKey];
    }
    return request;
}



#pragma mark-Private Methods

//设置请求头
+(void)setHttpHeader:(NSString *)header value:(NSString *)value
{
    [staticHttpClient.requestSerializer setValue:value forHTTPHeaderField:header];
}
//网络请求
+(NSMutableURLRequest *)requestWithMethod:(NetRequestMethodType)type path:(NSString *)path parameters:(NSDictionary *)params
{
    NSString *fullPath=[[staticHttpClient.baseURL URLByAppendingPathComponent:path] absoluteString];
    return [self requestWithMethod:type URLString:fullPath parameters:params];
}
+(NSMutableURLRequest *)requestWithMethod:(NetRequestMethodType)type URLString:(NSString *)urlString parameters:(NSDictionary *)params
{
    NSString *method=@"";
    if (type==NetRequestMethodType_Get)
    {
        method=@"GET";
    }
    else if (type==NetRequestMethodType_Post)
    {
        method=@"POST";
    }

    if (method&&[method length])
    {
        NSMutableURLRequest *request=[staticHttpClient.requestSerializer requestWithMethod:method URLString:urlString parameters:params error:nil];
        return request;

    }
    return nil;
}

+(void)setAuthToken:(NSString *)token
{
    //AppToken 仅在用户注册尚未完全完成时使用且仅保存一周  当获取autuToken后就需要清空
    if (token)
    {
        [self setAppToken:nil];
    }
    [self setHttpHeader:BDAuthTokenHeaderKey value:token];
}
+(void)setAppToken:(NSString *)token
{
    [self setHttpHeader:BDAppTokenHeaderKey value:token];
}
+(NSURLRequest *)appTokenRequest
{
    NSDictionary *params=@{
                           @"client_id":[BDAppKeys new].BDAppAPIClientKey,
                           @"client_secret":[BDAppKeys new].BDAppAPIClientSecret,
                           };
    
    return [self requestWithMethod:NetRequestMethodType_Get path:BDAppTokenURL parameters:params];
    
}

+(NSURLRequest *)createUserRequestWithName:(NSString *)name email:(NSString *)email password:(NSString *)password
{
    NSDictionary *params=@{@"email":email,@"password":password,@"name":name};
    return [self requestWithMethod:NetRequestMethodType_Post URLString:BDCreateUserURL parameters:params];
}





@end
