//
//  BDSystemTimeModel.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDBaseModel.h"

@interface BDSystemTimeModel : BDBaseModel

//服务器时间(ISO8601时间)
-(NSDate *)date;
//时间间隔
-(NSTimeInterval)timeIntervalSinceDate:(NSDate *)date;
@end
