//
//  BDViewModelIntercepter.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/29.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDViewModelIntercepter.h"
#import "NSObject+BDNonBase.h"
#import "BDViewModelProtocol.h"
#import <Aspects/Aspects.h>

@implementation BDViewModelIntercepter

+(void)load
{
    [super load];
    [BDViewModelIntercepter sharedInstance];
}
+(instancetype)sharedInstance
{
    static BDViewModelIntercepter *sharedIns;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedIns=[[BDViewModelIntercepter alloc]init];
    });
    return sharedIns;
}

-(instancetype)init
{
    self=[super init];
    if (self)
    {
        /*
         *方法拦截
         */
        [NSObject aspect_hookSelector:@selector(initWithParams:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo>aspectInfo,NSDictionary *params){
            
            [self hook_initWithInstance:aspectInfo.instance params:params];
            
        } error:nil];
    }
    return self;
}

#pragma mark-Hook Methods
-(void)hook_initWithInstance:(NSObject<BDViewModelProtocol> *)viewModel params:(NSDictionary *)params
{
    if ([viewModel respondsToSelector:@selector(bd_initialDataForViewModel)])
    {
        [viewModel bd_initialDataForViewModel];
    }

}
-(void)hook_initWithInstance:(NSObject<BDViewModelProtocol> *)viewModel
{
    if ([viewModel respondsToSelector:@selector(bd_initialDataForViewModel)])
    {
        [viewModel bd_initialDataForViewModel];
    }
}




@end
