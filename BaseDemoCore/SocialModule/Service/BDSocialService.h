//
//  BDSocialService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/25.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDSocialService : NSObject

+(instancetype)sharedService;

//获取话题列表
-(void)getSocialTopicListForType:(NSInteger)topicListType brandId:(NSString *)brandId userId:(NSString *)userId keyword:(NSString *)keyword page:(NSUInteger)page pageSize:(NSUInteger)pageSize complete:(void(^)(NSArray *topicArray,NSError *error))complete;



@end
