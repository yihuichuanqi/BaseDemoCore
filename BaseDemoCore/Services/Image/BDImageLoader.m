//
//  BDImageLoader.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDImageLoader.h"
#import "BDConfigService.h"
#import "BDImageCache.h"
#import "SDWebImageManager+BD.h"
#import "NSError+BD.h"
#import "UIImageView+BDWebImageCacheEx.h"

@implementation BDImageLoader

+(instancetype)sharedLoader
{
    static BDImageLoader *loader=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader=[[BDImageLoader alloc]init];
    });
    return loader;
}
-(instancetype)init
{
    if (self=[super init])
    {
        _previewImageUrlCache=[NSCache new];
        _previewImageUrlCache.countLimit=1000;
    }
    return self;
}

-(UIImage *)getLocalImageWithPath:(NSString *)imagePath
{
    UIImage *image=nil;
    if (imagePath.length>0)
    {
        //先检查配置包中是否存在图片
        image=[self getPackageImageWithPath:imagePath];
        if (image==nil)
        {
            //获取mainbundle中图片
            image=[UIImage imageNamed:getConfigImageNameInBundle(imagePath)];
        }
    }
    return image;
}
-(UIImage *)getPackageImageWithPath:(NSString *)imagePath
{
    UIImage *image=nil;
    //获取配置包图片
    NSString *configImagePath=[[BDConfigService sharedService].configPackagePath stringByAppendingPathComponent:imagePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:configImagePath])
    {
        //配置包中的图片添加到内存中
        image=[[BDImageCache sharedCache] imageWithContentOfFile:configImagePath];
    }
    return image;
}
-(void)checkPackageImageWithPath:(NSString *)imagePath
{
    if (imagePath.length>0&&[self getPackageImageWithPath:imagePath]==nil)
    {
        //图片缺失
        NSLog(@"PackageImage Loss:%@",imagePath);
    }
}

-(void)uploadImage:(UIImage *)image complete:(void (^)(NSURL *, NSString *, NSError *))complete
{
    if (complete!=nil)
    {
        complete(nil,nil,[NSError bd_Error:@"ERROR:Method Not Implemnet Yet!!!!"]);
    }
}
-(NSURL *)imageUrl:(NSURL *)originUrl withPreferSize:(CGSize)preferSize
{
    //preferSize{130,80}
    if (CGSizeEqualToSize(preferSize, CGSizeZero))
    {
        return originUrl;
    }
    NSString *imageExtension=originUrl.absoluteString.pathExtension;
    NSString *imagePath=originUrl.absoluteString;
    NSString *sizeSuffix;
    CGFloat screenScale=[UIScreen mainScreen].scale;
    if (preferSize.width==0)
    {
        sizeSuffix=[NSString stringWithFormat:@"_-%zd",(NSInteger)(preferSize.height*screenScale)];
    }
    else if (preferSize.height==0)
    {
        sizeSuffix=[NSString stringWithFormat:@"_%zd-",(NSInteger)(preferSize.width*screenScale)];
    }
    else
    {
        sizeSuffix=[NSString stringWithFormat:@"_%zdx%zd",(NSInteger)(preferSize.width*screenScale),(NSInteger)(preferSize.height*screenScale)];
    }
    imagePath=[imagePath stringByAppendingString:sizeSuffix];
    if (imageExtension.length>0)
    {
        imagePath=[NSString stringWithFormat:@"%@.%@",imagePath,imageExtension];
    }
    NSURL *preferSizeUrl=[NSURL URLWithString:imagePath];
    if (preferSizeUrl!=nil)
    {
        [self.previewImageUrlCache setObject:preferSizeUrl forKey:originUrl];
        return preferSizeUrl;
    }
    return originUrl;
}

#pragma mark-C inline Method
static inline NSString *getConfigImageNameInBundle(NSString *imagePath)
{
    return [imagePath.stringByDeletingPathExtension.pathComponents componentsJoinedByString:@"|"];
}


@end


@implementation UIImageView (BDImageLoader)

-(void)bd_setLocalImagePath:(NSString *)imagePath
{
    self.image=[[BDImageLoader sharedLoader] getLocalImageWithPath:imagePath];
}
-(void)bd_setImageWithUrl:(NSURL *)url preferSize:(CGSize)preferSize
{
    [self bd_setImageWithUrl:url preferSize:preferSize placeholderImage:nil];
}
-(void)bd_setImageWithUrl:(NSURL *)url preferSize:(CGSize)preferSize placeholderImage:(UIImage *)placeholder
{
    [self bd_setImageWithUrl:url preferSize:preferSize placeholderImage:placeholder completed:nil];
}
-(void)bd_setImageWithUrl:(NSURL *)url preferSize:(CGSize)preferSize placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlcok
{
    [self bd_setImageWithUrl:url preferSize:preferSize placeholderImage:placeholder options:0 completed:completedBlcok];
}
-(void)bd_setImageWithUrl:(NSURL *)url preferSize:(CGSize)preferSize placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlcok
{
    [self bd_setImageWithUrl:url preferSize:preferSize placeholderImage:placeholder options:options progress:nil completed:completedBlcok];
}
-(void)bd_setImageWithUrl:(NSURL *)url preferSize:(CGSize)preferSize placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlcok
{
    //最终调用SDWebImage
    [self sd_cancelCurrentImageLoad];
    SDImageCacheType cacheType=SDImageCacheTypeNone;
    UIImage *cacheImage=[[SDWebImageManager sharedManager] bd_cacheImageForUrl:url cacheType:&cacheType];
    if (cacheImage!=nil)
    {
        __weak __typeof(self)weakSelf=self;
        //主线程异步操作
        dispatch_main_async_safe(^{
            
            //先移除palceholder的subView
            if(self.bd_DefaultPlaceholderView)
            {
                [self.bd_DefaultPlaceholderView removeFromSuperview];
            }
            if (cacheImage&&(options&SDWebImageAvoidAutoSetImage)&&completedBlcok)
            {
                completedBlcok(cacheImage,nil,cacheType,url);
                return ;
            }
            else if (cacheImage)
            {
                weakSelf.image=cacheImage;
                [weakSelf setNeedsLayout];
            }
            if (completedBlcok)
            {
                completedBlcok(cacheImage,nil,cacheType,url);
            }
            
        });
    }
    else
    {
        [self sd_setImageWithURL:[[BDImageLoader sharedLoader] imageUrl:url withPreferSize:preferSize] placeholderImage:placeholder options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
           
            //图片加载失败 尝试加载原图
            if (image==nil&&error!=nil)
            {
                [self sd_setImageWithURL:url placeholderImage:placeholder options:options completed:completedBlcok];
            }
            else
            {
                if (completedBlcok!=nil)
                {
                    completedBlcok(image,error,cacheType,imageURL);
                }
            }
            
        }];
    }
    
}

@end






