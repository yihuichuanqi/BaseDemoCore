//
//  BDKeyChainUtil.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDKeyChainUtil.h"

@implementation BDKeyChainUtil


-(void)removeKeyChainStringForKey:(NSString *)key
{
    NSString *service=[UICKeyChainStore defaultService];
    [UICKeyChainStore removeItemForKey:key service:service accessGroup:self.accessGroup];
}
-(NSString *)keyChainStringForKey:(NSString *)key
{
    NSString *service=[UICKeyChainStore defaultService];
    return [UICKeyChainStore stringForKey:key service:service accessGroup:self.accessGroup];
}
-(void)setKeyChainStringForKey:(NSString *)key value:(NSString *)value
{
    NSString *service=[UICKeyChainStore defaultService];
    [UICKeyChainStore setString:value forKey:key service:service accessGroup:self.accessGroup];
}
#pragma mark-Private
-(NSString *)accessGroup
{
    NSDictionary *info=[[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:@"%@%@.keychain-group",info[@"AppIdentifierPrefix"],info[@"CFBundleIdentifier"]];
}

@end

@implementation BDDictionaryBackedKeyChain

-(instancetype)init
{
    self=[super init];
    if (!self)
    {
        return nil;
    }
    _dict=[NSMutableDictionary dictionary];
    return self;
}
-(NSString *)keyChainStringForKey:(NSString *)key
{
    return self.dict[key];
}
-(void)removeKeyChainStringForKey:(NSString *)key
{
    [self.dict removeObjectForKey:key];
}
-(void)setKeyChainStringForKey:(NSString *)key value:(NSString *)value
{
    [self.dict setObject:value forKey:key];
}
@end







