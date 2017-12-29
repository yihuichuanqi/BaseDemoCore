//
//  NSKeyedUnarchiver+ErrorLogging.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSKeyedUnarchiver (ErrorLogging)

+(id)unarchiveObjectWithFile:(NSString *)path exceptionBlock:(id(^)(NSException *exception))exceptionBlock;
@end
