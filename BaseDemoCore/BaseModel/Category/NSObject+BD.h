//
//  NSObject+BD.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*
 *NSObject 扩展通用功能
 */

#import <Foundation/Foundation.h>

extern id bd_castObj(id obj,Class aClass);

@interface NSObject (BD)

@property NSObject *bd_exObject;

@end
