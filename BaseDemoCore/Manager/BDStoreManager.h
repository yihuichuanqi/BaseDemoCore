//
//  BDStoreManager.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/8.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <YTKKeyValueStore/YTKKeyValueStore.h>

#define kBDStoreDBName  @"bd_db"  //数据库存储名称
#define kBDStorePathPlanHistory_Table @"kBDStorePathPlanHistory_Table" //行程规划历史信息



@interface BDStoreManager : YTKKeyValueStore


+(instancetype)manager;
@end
