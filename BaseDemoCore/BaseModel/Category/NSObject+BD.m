//
//  NSObject+BD.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "NSObject+BD.h"
#import <objc/runtime.h>

static char kEx_Object_BD; //新添属性地址key

//获取指定《类对象》
inline id bd_castObj(id obj,Class aClass)
{
    return [obj isKindOfClass:aClass]?obj:nil;
}

@implementation NSObject (BD)

-(void)setBd_exObject:(NSObject *)bd_exObject
{
    objc_setAssociatedObject(self, &kEx_Object_BD,bd_exObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSObject *)bd_exObject
{
    return objc_getAssociatedObject(self, &kEx_Object_BD);
}










@end
