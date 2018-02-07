//
//  BDUploadImageService.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDUploadImageService.h"
#import "BDImageUrl.h"
#import "BDRequestManager.h"
#import "NSError+BD.h"
#import "NSDictionary+BD.h"
#import "NSArray+BD.h"

@implementation BDUploadImageService

+(instancetype)sharedService
{
    static BDUploadImageService *service=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[BDUploadImageService alloc]init];
    });
    return service;
}
-(void)uploadImagewithImage:(UIImage *)image block:(void (^)(BDImageUrl *, NSError *))block
{
    NSDate *date=[NSDate date];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
    NSString *dateString=[formatter stringFromDate:date];
    [self uploadImagewithImage:image imageName:dateString block:block];
}
-(void)uploadImagewithImage:(UIImage *)image imageName:(NSString *)imageName block:(void (^)(BDImageUrl *, NSError *))block
{
    [[BDRequestManager requestManager] uploadImageWithPath:@"common/uploadImg" parameter:nil image:image imageName:imageName responseSuccess:^(BDServerResponse *serverResonse) {
        
        if (serverResonse.objData)
        {
            if (block)
            {
                BDImageUrl *imageUrl=[[BDImageUrl alloc]initWithAttributes:serverResonse.objData];
                block(imageUrl,nil);
            }
        }
        
    } error:^(NSString *msg, NSString *code) {
        
        if (block)
        {
            block(nil,[NSError bd_Error:msg revCode:[code integerValue]]);
        }
    }];
}
-(void)uploadVideoWithVideo:(NSString *)video block:(void(^)(NSDictionary *videoDic,NSError *error))block
{
    
}

-(void)uploadImage:(UIImage *)image block:(void(^)(NSDictionary *imageDic,NSError *error))block
{
    [[BDRequestManager requestManager] uploadImageWithPath:@"common/uploadImg" parameter:nil image:image imageName:[self getUploadSourceName:YES] responseSuccess:^(BDServerResponse *serverResonse) {
        
    } error:^(NSString *msg, NSString *code) {
        
    }];
}

-(void)uploadImages:(NSArray<UIImage *> *)images block:(void(^)(NSArray *imageDicts,NSError *error))complete
{
    NSMutableArray *imageDictArray=[NSMutableArray array];
    NSMutableDictionary *unOrderDic=[NSMutableDictionary dictionary];
    NSLock *lock=[[NSLock alloc]init];
    __block NSError *overAllError=nil;
    
    __block void(^UploadResult)(NSArray *imageDicts,NSError *error)=complete;
    dispatch_group_t group=dispatch_group_create();
    for (int idx=0; idx<images.count; idx++)
    {
        dispatch_group_enter(group);
        UIImage *image=[images bd_safeObjectAtIndex:idx];
        image.bd_exObject=@(idx);
        //单次上传
        [[BDUploadImageService sharedService] uploadImage:image block:^(NSDictionary *imageDic, NSError *error) {
           
            if (error)
            {
                overAllError=error;
                if (UploadResult)
                {
                    UploadResult(nil,overAllError);
                    UploadResult=nil;
                }
            }
            [lock lock];
            overAllError=error;
            if (imageDic)
            {
                [unOrderDic bd_safeSetObject:imageDic forKey:image.bd_exObject];
            }
            [lock unlock];
            //todo
            dispatch_group_leave(group);
            
        }];
    }
    dispatch_notify(group, dispatch_get_main_queue(), ^{
        
        if (overAllError&&UploadResult)
        {
            UploadResult(nil,overAllError);
        }
        else
        {
            if (UploadResult)
            {
                for (int idx=0; idx<unOrderDic.count; idx++)
                {
                    NSDictionary *imageDic=[unOrderDic bd_safeObjectForKey:@(idx)];
                    [imageDictArray addObject:imageDic];
                }
                UploadResult(imageDictArray,overAllError);
            }
        }
        
    });
}



//分析视频还是图片
-(NSString *)getUploadSourceName:(BOOL)isImage
{
    //根据时间
    NSDate *date=[NSDate date];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
    NSString *dateString=[formatter stringFromDate:date];
    NSString *type=isImage?@".jpg":@".mp4";
    NSString *fileName=[NSString stringWithFormat:@"%@%@",dateString,type];
    return [NSMutableString stringWithFormat:@"%@%@",[[NSUUID UUID]UUIDString],fileName];
}






@end
