//
//  NSObject+BDNonBase.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/29.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "NSObject+BDNonBase.h"
#import <objc/runtime.h>

static const void *kParamsKey=&kParamsKey;

@implementation NSObject (BDNonBase)

-(void)setParams:(NSDictionary *)params
{
    objc_setAssociatedObject(self, kParamsKey, params, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(NSDictionary *)params
{
    return objc_getAssociatedObject(self, kParamsKey);
}

-(instancetype)initWithParams:(NSDictionary *)params
{
    if (self=[self init])
    {
        [self setParams:params];
    }
    return self;
}



@end
