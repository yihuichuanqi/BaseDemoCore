//
//  BDUploadImageService.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*图片上传服务类*/

#import <Foundation/Foundation.h>

@class BDImageUrl;

@interface BDUploadImageService : NSObject

+(instancetype)sharedService;

//根据时间生成图片名称
-(void)uploadImagewithImage:(UIImage *)image block:(void(^)(BDImageUrl *imageModel,NSError *error))block;
-(void)uploadImagewithImage:(UIImage *)image imageName:(NSString *)imageName block:(void(^)(BDImageUrl *imageModel,NSError *error))block;

-(void)uploadVideoWithVideo:(NSString *)video block:(void(^)(NSDictionary *videoDic,NSError *error))block;
-(void)uploadImages:(NSArray<UIImage *> *)images block:(void(^)(NSArray *imageDicts,NSError *error))complete;

@end
