//
//  UIImageView+BDWebImageCacheEx.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "UIImageView+BDWebImageCacheEx.h"
#import "BDMethodSwizzingUtil.h"
#import "BDImageLoader.h"
#import <SDWebImage/UIImageView+WebCache.h>

static char HandleLoadFailKey;
static char LastLoadUrlKey;
static char LoadFailImageKey;

@implementation UIImageView (BDWebImageCacheEx)


+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [BDMethodSwizzingUtil swizzinClass:self OriginalSEL:@selector(sd_setImageWithURL:placeholderImage:options:progress:completed:) TonewSEL:@selector(swizz_setImageWithURL:placeholderImage:options:progress:completed:)];
    });
}

#pragma mark-Property
-(BOOL)bd_handleLoadFail
{
    NSNumber *handleLoadFailNumber=objc_getAssociatedObject(self, &HandleLoadFailKey);
    if (handleLoadFailNumber==nil||![handleLoadFailNumber isKindOfClass:[NSNumber class]])
    {
        return NO;
    }
    else
    {
        return [handleLoadFailNumber boolValue];
    }
}
-(void)setBd_handleLoadFail:(BOOL)bd_handleLoadFail
{
    [self bd_setHandleLoadFail:bd_handleLoadFail];
}
-(void)bd_setHandleLoadFail:(BOOL)handleLoadFail
{
    objc_setAssociatedObject(self, &HandleLoadFailKey, @(handleLoadFail), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(BOOL)bd_useDefaultPlaceholder
{
    NSNumber *useDefaultPlaceholder=objc_getAssociatedObject(self, _cmd);
    return [useDefaultPlaceholder boolValue];
}
-(void)setBd_useDefaultPlaceholder:(BOOL)bd_useDefaultPlaceholder
{
    [self bd_setUseDefaultPlaceholder:bd_useDefaultPlaceholder];
}
-(void)bd_setUseDefaultPlaceholder:(BOOL)useDefaultPlaceholder
{
    objc_setAssociatedObject(self, @selector(bd_useDefaultPlaceholder), @(useDefaultPlaceholder), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(UIImage *)bd_loadFailImage
{
    UIImage *failImage=objc_getAssociatedObject(self, &LoadFailImageKey);
    if (failImage==nil&&![failImage isKindOfClass:[UIImage class]])
    {
        return [self defaultLoadFailImage];
    }
    return failImage;
}
-(void)bd_setLoadFailImage:(UIImage *)bd_loadFailImage
{
    objc_setAssociatedObject(self, &LoadFailImageKey, bd_loadFailImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (bd_loadFailImage!=nil)
    {
        self.bd_handleLoadFail=YES;
    }
}

-(UIView *)bd_DefaultPlaceholderView
{
    UIImageView *defaultPlaceholderView=objc_getAssociatedObject(self, _cmd);
    if (defaultPlaceholderView==nil)
    {
        defaultPlaceholderView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"image_placeholder"]];
        defaultPlaceholderView.contentMode=UIViewContentModeCenter;
        defaultPlaceholderView.backgroundColor=[UIColor lightGrayColor];
        defaultPlaceholderView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        objc_setAssociatedObject(self, _cmd, defaultPlaceholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    defaultPlaceholderView.frame=self.bounds;
    return defaultPlaceholderView;
}

-(NSURL *)bd_lastLoadUrl
{
    NSURL *url=objc_getAssociatedObject(self, &LastLoadUrlKey);
    if (url==nil&&![url isKindOfClass:[NSURL class]])
    {
        return nil;
    }
    return url;
}
-(void)bd_setLastLoadUrl:(NSURL *)bd_lastLoadUrl
{
    objc_setAssociatedObject(self, &LastLoadUrlKey, bd_lastLoadUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark-Swizz Method
-(void)swizz_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock
{
    //placeholder处理
    if (placeholder==nil&&self.bd_useDefaultPlaceholder)
    {
        [self addSubview:self.bd_DefaultPlaceholderView];
    }
    else
    {
        [self.bd_DefaultPlaceholderView removeFromSuperview];
    }
    //加载失败
    SDWebImageCompletionBlock completedBlockWithLoadErrorHandler=^(UIImage *image,NSError *error,SDImageCacheType cacheType,NSURL *imageURL){
        
        [self.bd_DefaultPlaceholderView removeFromSuperview];
        BOOL loadFail=(image==nil||error!=nil);
        if (loadFail)
        {
            if (self.bd_handleLoadFail)
            {
                self.defaultLoadHandler(image,error,cacheType,imageURL);
            }
        }
        if (completedBlock!=nil)
        {
            completedBlock(image,error,cacheType,imageURL);
        }
    };
    [self swizz_setImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed:completedBlockWithLoadErrorHandler];
    
}

-(SDWebImageCompletionBlock)defaultLoadHandler
{
    return ^(UIImage *image,NSError *error,SDImageCacheType cacheType,NSURL *imageURL){
        
        self.image=[self bd_loadFailImage];
    };
}

-(UIImage *)defaultLoadFailImage
{
    return [UIImage imageNamed:@"image_load_fail"];
}



@end
