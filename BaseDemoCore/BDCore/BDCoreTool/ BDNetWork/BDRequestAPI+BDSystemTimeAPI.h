//
//  BDRequestAPI+BDSystemTimeAPI.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/21.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDRequestAPI.h"

@class BDSystemTimeModel;
@interface BDRequestAPI (BDSystemTimeAPI)

+(void)getSystemTime:(void(^)(BDSystemTimeModel *systemTime))success failure:(ResponseErrorCodeMessageBlock)failure;

@end
