//
//  BDRequestManager.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/19.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDRequestManager.h"
#import "BDServerResponseSerializer.h"
#import "UIImage+BD.h"


#define kStagingAPIBase @"https://app-api.chargerlink.com/"

@interface BDRequestManager ()
{
    AFHTTPSessionManager *manager;
}
@end

@implementation BDRequestManager


+(instancetype)requestManager
{
    return [[[self class] alloc] initWithBaseUrl:[NSURL URLWithString:kStagingAPIBase]];
}
+(instancetype)nonJsonRequestManager
{
    return [[[self class] alloc] initWithBaseUrl:[NSURL URLWithString:kStagingAPIBase] jsonResponse:NO];
}
-(id)initWithBaseUrl:(NSURL *)url
{
    return [self initWithBaseUrl:url jsonResponse:YES];
}
-(id)initWithBaseUrl:(NSURL *)url jsonResponse:(BOOL)jsonResponse
{
    if (self=[super init])
    {
        [self configManagerWithBaseUrl:url jsonResponse:YES];
    }
    return self;
}
-(void)configManagerWithBaseUrl:(NSURL *)url jsonResponse:(BOOL)jsonResponse
{
    //设置信任非法证书
    if (url)
    {
        manager=[[AFHTTPSessionManager alloc]initWithBaseURL:url];
    }
    else
    {
        manager=[AFHTTPSessionManager manager];
    }
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    [manager.securityPolicy setValidatesDomainName:NO];
    manager.responseSerializer=jsonResponse?[BDServerResponseSerializer serializer]:[AFHTTPResponseSerializer serializer];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval=30.0;
    [self addRequestSerializerHeaderFiled];

}
//添加默认请求头
-(void)addRequestSerializerHeaderFiled
{
    if (manager)
    {
        [manager.requestSerializer setValue:[self deviceString] forHTTPHeaderField:@"DEVICE"];
//        [manager.requestSerializer setValue:@"" forHTTPHeaderField:@"TOKEN"];
    }
}
-(NSString *)deviceString
{
    NSString *bundleVersion=@"3.7.4.1";
    NSString *iosVersion=@"11.2";
    NSString *hardwareType=@"x86_64";
    NSString *iosCarrier=@"UnKnow";
    NSString *pushType=@"0";
    NSString *lan=@"ch";
    NSString *deviceId=@"18238d4f9a8434d45d8bc847c833f124";
    NSString *cityCode=@"";
    NSString *lat=@"0.000000";
    NSString *lng=@"0.000000";
    NSString *cityName=@"";
    return [NSString stringWithFormat:@"ver=%@&os_version=%@&device_type=%@&carrier=%@&client=ios&pushtype=%@&lan=%@&device_id=%@&cityCode=%@&lat=%@&lat=%@&cityName=%@",bundleVersion,iosVersion,hardwareType,iosCarrier,pushType,lan,deviceId,cityCode,lat,lng,cityName];
    
}


-(NSMutableDictionary *)baseParameters
{
    [self addRequestSerializerHeaderFiled];
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    return params;
}
-(void)requestWithPath:(NSString *)path parameter:(NSDictionary *)params responseSuccess:(ResponseSuccessBlock)successBlock error:(ResponseErrorBlock)errorBlock
{
    [self requestByPostWithPath:path parameter:params responseSuccess:successBlock error:errorBlock];
}

#pragma mark-Private Method
//真正执行请求
-(void)requestActualWithMethod:(NSString *)method path:(NSString *)path parameter:(NSDictionary *)params responseSuccess:(ResponseSuccessBlock)successBlock error:(ResponseErrorBlock)errorBlock
{
    if(manager)
    {
        void (^loadSuccessBlock)(NSURLSessionDataTask *task,BDServerResponse *responseObject)=^(NSURLSessionDataTask *task,BDServerResponse *responseObject){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //如果token存在并且与本地用户保存一直,然后判断是否过期
                NSString *token=@"";
                if (token.length&&[token isEqualToString:@"localToken"]&&[responseObject.code isEqualToString:kServerCode_Token_Expire])
                {
                    if (errorBlock)
                    {
                        errorBlock(responseObject.msg,responseObject.code);
                    }
                    return ;
                }
                if([responseObject.code isEqualToString:kServerCode_Ok])
                {
                    if (successBlock)
                    {
                        successBlock(responseObject);
                    }
                    return;
                }
                if (errorBlock)
                {
                    errorBlock(responseObject.msg,responseObject.code);
                }
                
                
            });
            
        };
        void (^loadErrorBlock)(NSURLSessionDataTask *task,NSError *error)=^(NSURLSessionDataTask *task,NSError *error){
          
            if (errorBlock)
            {
                NSString *errorMsg=[error localizedDescription];
                NSInteger errorCode=[error code];
                errorBlock(errorMsg,[@(errorCode) stringValue]);
            }
        };
        
        if ([method isEqualToString:@"POST"])
        {
            [manager POST:path parameters:params progress:nil success:loadSuccessBlock failure:loadErrorBlock];

        }
        else
        {
            [manager GET:path parameters:params progress:nil success:loadSuccessBlock failure:loadErrorBlock];
        }
        
    }
}

-(void)requestByGetWithPath:(NSString *)path parameter:(NSDictionary *)params responseSuccess:(ResponseSuccessBlock)successBlock error:(ResponseErrorBlock)errorBlock
{
    [self requestActualWithMethod:@"GET" path:path parameter:params responseSuccess:successBlock error:errorBlock];
}
-(void)requestByPostWithPath:(NSString *)path parameter:(NSDictionary *)params responseSuccess:(ResponseSuccessBlock)successBlock error:(ResponseErrorBlock)errorBlock
{
    [self requestActualWithMethod:@"POST" path:path parameter:params responseSuccess:successBlock error:errorBlock];
}

-(void)uploadImageWithPath:(NSString *)path parameter:(NSDictionary *)params image:(UIImage *)image imageName:(NSString *)imageName responseSuccess:(ResponseSuccessBlock)successBlock error:(ResponseErrorBlock)errorBlock
{
    if (manager)
    {
        void (^uploadSuccessBlock)(NSURLSessionDataTask *task,BDServerResponse *responseObject)=^(NSURLSessionDataTask *task,BDServerResponse *responseObject){
            
            if([responseObject.code isEqualToString:kServerCode_Ok])
            {
                if (successBlock)
                {
                    successBlock(responseObject);
                }
                return;
            }
            if (errorBlock)
            {
                errorBlock(responseObject.msg,responseObject.code);
            }
        };
        void (^uploadErrorBlock)(NSURLSessionDataTask *task,NSError *error)=^(NSURLSessionDataTask *task,NSError *error){
            
            if (errorBlock)
            {
                NSString *errorMsg=[error localizedDescription];
                NSInteger errorCode=[error code];
                errorBlock(errorMsg,[@(errorCode) stringValue]);
            }
        };

        
        [manager POST:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            UIImage *fixedImage=[image bd_fixOrientation];
            NSData *imageData=UIImageJPEGRepresentation(fixedImage, 0.9);
            float i=0.8f;
            CGFloat max=[UIImage bd_caculateUploadImageFileSize:fixedImage.size];
            while (imageData.length>=max&&i>=0.3)
            {
                //大于 则要缩小压缩图片质量
                imageData=UIImageJPEGRepresentation(fixedImage, i);
                i-=0.2;
            }
            //文件名称
            NSString *fileName=imageName;
            //文件目录名称（暂且未用到）
            NSMutableString *name=[NSMutableString stringWithString:imageName];
            if (![imageName hasSuffix:@".jpg"])
            {
                fileName=[NSString stringWithFormat:@"%@.jpg",fileName];
            }
            else
            {
                [name stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
            }
            //添加个唯一字符串作为文件目录
            name=[NSMutableString stringWithFormat:@"%@%@",name,[[NSUUID UUID]UUIDString]];
            [formData appendPartWithFileData:imageData name:@"data" fileName:fileName mimeType:@"image/jpeg"];
            
        } progress:nil success:uploadSuccessBlock failure:uploadErrorBlock];
        
    }
}
-(void)uploadVideoWithPath:(NSString *)path parameter:(NSDictionary *)params videoModel:(NSString *)videoModel videoName:(NSString *)videoName imageName:(NSString *)imageName responseSuccess:(ResponseSuccessBlock)successBlock error:(ResponseErrorBlock)errorBlock
{
    if (manager)
    {
        void (^uploadSuccessBlock)(NSURLSessionDataTask *task,BDServerResponse *responseObject)=^(NSURLSessionDataTask *task,BDServerResponse *responseObject){
            
            if([responseObject.code isEqualToString:kServerCode_Ok])
            {
                if (successBlock)
                {
                    successBlock(responseObject);
                }
                return;
            }
            if (errorBlock)
            {
                errorBlock(responseObject.msg,responseObject.code);
            }
        };
        void (^uploadErrorBlock)(NSURLSessionDataTask *task,NSError *error)=^(NSURLSessionDataTask *task,NSError *error){
            
            if (errorBlock)
            {
                NSString *errorMsg=[error localizedDescription];
                NSInteger errorCode=[error code];
                errorBlock(errorMsg,[@(errorCode) stringValue]);
            }
        };
        [manager POST:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            NSURL *videoUrl;
            NSURL *videoThumbnailImageUrl;
            [formData appendPartWithFileURL:videoUrl name:@"video" fileName:videoName mimeType:@"video/mp4" error:nil];
            [formData appendPartWithFileURL:videoThumbnailImageUrl name:@"thumbnailImage" fileName:imageName mimeType:@"image/jpeg" error:nil];
            
        } progress:nil success:uploadSuccessBlock failure:uploadErrorBlock];
    }
}
+(void)addJpgImage:(UIImage *)image forKey:(NSString *)key toBody:(id<AFMultipartFormData>)formData
{
    if (image!=nil&&!isEmpty(key))
    {
        UIImage *fixedImage=image;
        //压缩
        CGFloat jpegCompressionQuality=0.9;
        NSData *imageData=UIImageJPEGRepresentation(fixedImage, jpegCompressionQuality);
        //增加压缩比例以避免拍照上传失败的情况
        NSUInteger imageDataSize=imageData.length;
        while (imageDataSize>1000000&&jpegCompressionQuality>0.1)
        {
            jpegCompressionQuality-=0.1;
            imageData=UIImageJPEGRepresentation(fixedImage, jpegCompressionQuality);
            imageDataSize=imageData.length;
        }
        [formData appendPartWithFileData:imageData name:key fileName:[[NSUUID UUID] UUIDString] mimeType:@"image/jpeg"];
        
    }
}
+(void)addJpgImages:(NSArray *)images forKey:(NSString *)key toBody:(id<AFMultipartFormData>)formData
{
    
}



@end
