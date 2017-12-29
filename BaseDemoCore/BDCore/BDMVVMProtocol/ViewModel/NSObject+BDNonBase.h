//
//  NSObject+BDNonBase.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/29.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BDNonBase)

//去表征化参数列表
@property (nonatomic,strong,readonly) NSDictionary *params;
//初始化
-(instancetype)initWithParams:(NSDictionary *)params;

@end
