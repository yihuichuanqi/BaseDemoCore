//
//  BDMQTTConfigService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/18.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDMQTTConfigService.h"
#import "EVCrypto.h"
#import "NSDictionary+BD.h"
#import "NSNotificationCenter+MainThread.h"

NSString * const BDMQTTConfigDidChangedNotification=@"BDMQTTConfigDidChangedNotification";


@implementation BDMQTTConfigService

+(instancetype)sharedService
{
    static BDMQTTConfigService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDMQTTConfigService alloc]init];
    });
    return service;
}

-(instancetype)init
{
    if (self=[super init])
    {
        _port=-1;
    }
    return self;
}
-(void)loadConfigWithAttributes:(id)aAttributes
{
    if (isEmpty(aAttributes))
    {
        return;
    }
    
    id attDict=[[EVCrypto decryptXXTEAWithString:aAttributes] mj_JSONObject];
    if (![attDict isKindOfClass:[NSDictionary class]])
    {
        attDict=nil;
    }
    
    NSString *host=[attDict bd_StringObjectForKey:@"host"];
    NSInteger port=[attDict bd_IntergerForKey:@"port"];
    NSString *userName=[attDict bd_StringObjectForKey:@"username"];
    NSString *passWord=[attDict bd_StringObjectForKey:@"password"];
    
    BOOL changed=NO;
    if ((_host&&![_host isEqualToString:host])||(_port!=-1&&_port!=port)||(_userName&&[_userName isEqualToString:userName])||(_passWord&&[_passWord isEqualToString:passWord]))
    {
        changed=YES;
    }
    _host=host;
    _port=port;
    _userName=userName;
    _passWord=passWord;
    if (changed)
    {
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:BDMQTTConfigDidChangedNotification object:nil];
    }
}










@end
