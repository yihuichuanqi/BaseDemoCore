//
//  UIImageView+BDAvartar.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/29.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "UIImageView+BDAvartar.h"
#import <ImageIO/ImageIO.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "BDImageLoader.h"
#import "SDWebImageManager+BD.h"
#import "UIView+BD.h"
#import "UIImage+BD.h"


@implementation UIImageView (BDAvartar)


-(void)bd_setAvartarForUrl:(NSURL *)url
{
    [self bd_setAvartarForUrl:url placeholderImage:nil];
}
-(void)bd_setAvartarForUrl:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
    [self sd_cancelCurrentImageLoad];
    if (!url||url.absoluteString.length==0)
    {
        [self setImage:placeholderImage];
        return;
    }
    BDCacheKeyType type=BDCacheKeyType_Avatar;
    UIImage *cachedFinalImage=[[SDWebImageManager sharedManager] bd_cacheImageForUrl:url type:type];
    if (cachedFinalImage==nil)
    {
        //注意SDWebImageCacheMemoryOnly，SDWebImageAvoidAutoSetImage 这两步都是手动完成的
        [self bd_setImageWithUrl:url preferSize:CGSizeMake(72, 72) placeholderImage:placeholderImage options:0|SDWebImageAvoidAutoSetImage|SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
         
            BOOL loadFail=(image==nil||error!=nil);
            if (loadFail)
            {
                [self setImage:placeholderImage];
            }
            else
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                   
                    CGImageRef ref=CGImageCreateWithImageInRect(image.CGImage, getCenterSquareRectOfSize(image.size));
                    UIImage *centerImage=[UIImage imageWithCGImage:ref];
                    UIImage *finalImage=[centerImage bd_imageWithSize:CGSizeMake(72, 72) radius:36];
                    [[SDWebImageManager sharedManager] bd_saveImageToCache:finalImage forUrl:url type:type];
                    
                   
                    dispatch_async(dispatch_get_main_queue(), ^{
                       
                        [self setImage:finalImage?finalImage:placeholderImage];
                    });
                });
            }
            
        }];

    }
    else
    {
        [self setImage:cachedFinalImage];
    }
    
}
-(void)bd_setContentImageForUrl:(NSURL *)url placeholderImage:(UIImage *)placeholderImage size:(CGSize)size
{
    if (!url)
    {
        [self setImage:nil];
        return;
    }
    if (!(size.width>0))
    {
        size=CGSizeMake(320, 320);
    }
    BDCacheKeyType type=BDCacheKeyType_Content;
    [[SDWebImageManager sharedManager] bd_diskImageExistsForUrl:url type:type complete:^(BOOL isInCache) {
        
        if (!isInCache)
        {
            [self sd_setImageWithURL:url placeholderImage:placeholderImage options:0|SDWebImageAvoidAutoSetImage|SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
               
                BOOL loadFail=(image==nil||error!=nil);
                if (loadFail)
                {
                    [self setImage:placeholderImage];
                }
                else
                {
                    __block UIImage *finalImage=image;
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       
                        
                        if (image.size.width>size.width*2||image.size.height>size.height*2)
                        {
                            finalImage=[self getThumbnailImageFromJPEGData:UIImageJPEGRepresentation(image, 0.9) withMax:MAX(size.width*2,size.height*2)];
                        }
                        [[SDWebImageManager sharedManager] bd_saveImageToCache:finalImage forUrl:url type:type];
                        dispatch_async(dispatch_get_main_queue(), ^{
                           
                            [self setImage:finalImage?finalImage:placeholderImage];
                        });
                        
                    });
                }
            }];
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               
                UIImage *finalImage=[[SDWebImageManager sharedManager] bd_cacheImageForUrl:url type:type];
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    [self setImage:finalImage?finalImage:placeholderImage];
                });
            });
        }
        
        
    }];
}


#pragma mark-Private Method
-(UIImage *)getThumbnailImageFromJPEGData:(NSData *)jpegData withMax:(CGFloat)max
{
    CGImageRef thumbnailCGImage=NULL;
    CGDataProviderRef provider=CGDataProviderCreateWithCFData((__bridge CFDataRef)jpegData);
    if (provider)
    {
        CGImageSourceRef imageSource=CGImageSourceCreateWithDataProvider(provider, NULL);
        if (imageSource)
        {
            if(CGImageSourceGetCount(imageSource)>0)
            {
                NSMutableDictionary *options=[[NSMutableDictionary alloc]initWithCapacity:3];
                options[(id)kCGImageSourceCreateThumbnailFromImageAlways]=@(YES);
                options[(id)kCGImageSourceThumbnailMaxPixelSize]=@(max);
                options[(id)kCGImageSourceCreateThumbnailWithTransform]=@(YES);
                thumbnailCGImage=CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
                
            }
            CFRelease(imageSource);
        }
        CGDataProviderRelease(provider);
    }
    UIImage *thumbnail=nil;
    if (thumbnailCGImage)
    {
        thumbnail=[[UIImage alloc]initWithCGImage:thumbnailCGImage];
        CGImageRelease(thumbnailCGImage);
    }
    return thumbnail;
}




@end
