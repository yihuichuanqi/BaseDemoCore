//
//  BDMethodSwizzingUtil.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/28.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDMethodSwizzingUtil.h"
#import <objc/runtime.h>

@implementation BDMethodSwizzingUtil

+ (void)swizzinClass:(Class)swizzingClass OriginalSEL:(SEL)originalSEL TonewSEL:(SEL)newSEL {
    Method originalMehtod = class_getInstanceMethod(swizzingClass, originalSEL);
    Method newMethod = class_getInstanceMethod(swizzingClass, newSEL);
    BOOL didAddMethod = class_addMethod(swizzingClass, originalSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (didAddMethod) {
        class_replaceMethod(swizzingClass, newSEL, method_getImplementation(originalMehtod), method_getTypeEncoding(originalMehtod));
    }else {
        method_exchangeImplementations(originalMehtod, newMethod);
    }
}

@end
