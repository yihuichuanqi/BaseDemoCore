//
//  BDRequestManager.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/19.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDServerResponse.h"

typedef void (^ResponseSuccessBlock)(BDServerResponse *serverResonse);
typedef void (^ResponseErrorBlock)(NSString *msg,NSString *code);

@interface BDRequestManager : NSObject

//请使用此方法初始化
+(instancetype)requestManager;
+(instancetype)nonJsonRequestManager;

//使用此方法会添加HeaderField
-(NSMutableDictionary *)baseParameters;


//请求数据（默认post）
-(void)requestWithPath:(NSString *)path parameter:(NSDictionary *)params responseSuccess:(ResponseSuccessBlock)successBlock error:(ResponseErrorBlock)errorBlock;
-(void)requestByGetWithPath:(NSString *)path parameter:(NSDictionary *)params responseSuccess:(ResponseSuccessBlock)successBlock error:(ResponseErrorBlock)errorBlock;
-(void)requestByPostWithPath:(NSString *)path parameter:(NSDictionary *)params responseSuccess:(ResponseSuccessBlock)successBlock error:(ResponseErrorBlock)errorBlock;
//上传图片
-(void)uploadImageWithPath:(NSString *)path parameter:(NSDictionary *)params image:(UIImage *)image imageName:(NSString *)imageName responseSuccess:(ResponseSuccessBlock)successBlock error:(ResponseErrorBlock)errorBlock;
-(void)uploadVideoWithPath:(NSString *)path parameter:(NSDictionary *)params videoModel:(NSString *)videoModel videoName:(NSString *)videoName imageName:(NSString *)imageName responseSuccess:(ResponseSuccessBlock)successBlock error:(ResponseErrorBlock)errorBlock;
+(void)addJpgImage:(UIImage *)image forKey:(NSString *)key toBody:(id<AFMultipartFormData>)formData;
+(void)addJpgImages:(NSArray *)images forKey:(NSString *)key toBody:(id<AFMultipartFormData>)formData;


@end
