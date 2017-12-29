//
//  BDBaseModel.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDBaseModel.h"

@implementation BDBaseModel

+(instancetype)initWithServerJson:(id)data
{
    id res=[self mj_objectWithKeyValues:data];
    return res;
}
@end
