//
//  BDJPushConfigManager.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/8.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDJPushConfigManager : NSObject

+(BDJPushConfigManager *)sharesInstance;

@property (nonatomic,strong) NSString *jPushAppNotiId;
@property (nonatomic,strong) NSString *jPushNotiAppKey;
@property (nonatomic,strong) NSString *jPushNotiSecret;


@end
