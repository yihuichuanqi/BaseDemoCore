//
//  BDRequestAPI.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDRequestAPI.h"
#import "BDDefaultsConst.h"

#import "BDRouter.h"

@implementation BDRequestAPI

+(void)getAppTokenWithCompletion:(void (^)(NSString *, NSDate *))callBack
{
    [self getAppTokenWithCompletion:callBack failure:nil];
}
+(void)getAppTokenWithCompletion:(void (^)(NSString *, NSDate *))callBack failure:(void (^)(NSError *))failureBlock
{
    [self.sharedAPI getAppTokenWithCompletion:callBack failure:failureBlock];
}

-(void)getAppTokenWithCompletion:(void (^)(NSString *, NSDate *))callBack failure:(void (^)(NSError *))failureBlock
{
    //检查 如果存在AppToken 则返回
    NSDate *appDate=[[NSUserDefaults standardUserDefaults] objectForKey:BDAppTokenExpiryDateDefaults];
    NSDate *authDate=[[NSUserDefaults standardUserDefaults] objectForKey:BDAuthTokenExpiryDefaults];
    
    NSString *appToken=[UICKeyChainStore stringForKey:BDAppTokenKeyChainKeyDefaults];
    NSString *authToken=[UICKeyChainStore stringForKey:BDAuthTokenDefaults];
    
    if ((appDate&&appToken)||(authDate&&appToken))
    {
        if (callBack)
        {
            callBack(appToken?:authToken,appDate?:authDate);
        }
    }
    
    NSURLRequest *tokenRequest=[BDRouter appTokenRequest];
    NSURLSessionDataTask *task=[self requestSessionDataTask:tokenRequest completionHandler:^(NSURLResponse *response, id responseObj, NSError *error) {
        
    }];
    
    [task resume];
    
}


#pragma mark-Private Method

-(NSURLSessionDataTask *)requestSessionDataTask:(NSURLRequest *)request completionHandler:(void(^)(NSURLResponse *response,id responseObj,NSError *error))completionHandler
{
    return nil;
//    NSURLSessionDataTask *task=[dataTaskWithRequest:request completionHandler:completionHandler];
//    return task;
}


+(BDRequestAPI *)sharedAPI
{
    static BDRequestAPI *_sharedController=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class kClass=NSClassFromString(@"BDOHHttpRequestAPI")?:self;
        _sharedController=[[kClass alloc]init];
    });
    return _sharedController;
}

@end
