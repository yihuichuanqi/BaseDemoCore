//
//  BDMineConfigManager.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/6.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BDMineConfigManagerInstance [BDMineConfigManager sharedInstance]

@interface BDMineConfigManager : NSObject

+(BDMineConfigManager *)sharedInstance;

//网络前缀
@property (nonatomic,strong) NSString *prefixNetworkUrl;

@end
