//
//  NSKeyedUnarchiver+ErrorLogging.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "NSKeyedUnarchiver+ErrorLogging.h"

@implementation NSKeyedUnarchiver (ErrorLogging)
+(id)unarchiveObjectWithFile:(NSString *)path exceptionBlock:(id(^)(NSException *exception))exceptionBlock
{
    @try{
        
        return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    @catch (NSException *exception) {
        
        return exceptionBlock(exception);
    }
}
@end
