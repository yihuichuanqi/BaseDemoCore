//
//  BDMethodSwizzingUtil.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/28.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDMethodSwizzingUtil : NSObject

/**
 方法交换
 
 @param swizzingClass 类
 @param originalSEL 旧方法
 @param newSEL 新方法
 */
+ (void)swizzinClass:(Class)swizzingClass OriginalSEL:(SEL)originalSEL TonewSEL:(SEL)newSEL;

@end
