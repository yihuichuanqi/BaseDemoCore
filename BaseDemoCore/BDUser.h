//
//  BDUser.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/20.
//  Copyright © 2017年 Admin. All rights reserved.
//

/*
 *手机登录账户信息
 */

#import <Foundation/Foundation.h>
#import "BDBaseModel.h"

@class BDUserProfile;

@interface BDUser : BDBaseModel

@property (nonatomic,strong) BDUserProfile *profile;

@property (nonatomic,copy,readonly) NSString *userId;
@property (nonatomic,copy,readonly) NSString *name;
@property (nonatomic,copy,readonly) NSString *phone;
@property (nonatomic,copy,readonly) NSString *email;

//当期用户模型
+(BDUser *)currentUser;
//是否是暂时本地用户
+(BOOL)isLocalTemporaryUser;














@end
