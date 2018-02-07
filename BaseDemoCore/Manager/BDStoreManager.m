//
//  BDStoreManager.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDStoreManager.h"

@implementation BDStoreManager

+(instancetype)manager
{
    static BDStoreManager *manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager =[[BDStoreManager alloc]init];
    });
    return manager;
}

-(id)init
{
    if (self=[super initDBWithName:kBDStoreDBName])
    {
        [self createTableWithName:kBDStorePathPlanHistory_Table];
    }
    return self;
}








@end
