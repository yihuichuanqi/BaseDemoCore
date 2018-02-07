//
//  SDWebImageManager+BD.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "SDWebImageManager+BD.h"
#import "BDImageLoader.h"

@implementation SDWebImageManager (BD)

-(void)bd_saveImageToCache:(UIImage *)image forKey:(NSString *)cacheKey
{
    if (image&&cacheKey)
    {
        [self.imageCache storeImage:image forKey:cacheKey toDisk:YES];
    }
}

-(UIImage *)bd_cacheImageForKey:(NSString *)cacheKey
{
    return [self.imageCache imageFromDiskCacheForKey:cacheKey];
}
-(UIImage *)bd_cacheImageForKey:(NSString *)cacheKey cahceType:(SDImageCacheType *)cacheType
{
    //先获取缓存图片
    UIImage *image=[self.imageCache imageFromMemoryCacheForKey:cacheKey];
    if(image!=nil)
    {
        *cacheType=SDImageCacheTypeMemory;
        return image;
    }
    //然后获取硬盘图片
    UIImage *diskImage=[self.imageCache imageFromDiskCacheForKey:cacheKey];
    if (diskImage!=nil)
    {
        *cacheType=SDImageCacheTypeDisk;
        return diskImage;
    }
    *cacheType=SDImageCacheTypeNone;
    return nil;
}
-(void)bd_saveImageToCacheIfNotExist:(UIImage *)image forUrl:(NSURL *)url
{
    [self cachedImageExistsForURL:url completion:^(BOOL isInCache) {
       
        if (!isInCache)
        {
            [self saveImageToCache:image forURL:url];
        }
    }];
}

//先从SD的缓存机制中查询 然后在从自定义缓存机制中查询
-(UIImage *)bd_cacheImageForUrl:(NSURL *)url
{
    return [self bd_cacheImageForKey:[self cacheKeyForURL:url]]?:[self bd_cacheImageForKey:[self cacheKeyForURL:[[BDImageLoader sharedLoader].previewImageUrlCache objectForKey:url]]];
}
-(UIImage *)bd_cacheImageForUrl:(NSURL *)url cacheType:(SDImageCacheType *)cacheType
{
    return [self bd_cacheImageForKey:[self cacheKeyForURL:url] cahceType:cacheType]?:[self bd_cacheImageForKey:[self cacheKeyForURL:[[BDImageLoader sharedLoader].previewImageUrlCache objectForKey:url]] cahceType:cacheType];
}

-(void)bd_downloadImageToCacheForUrl:(NSURL *)url
{
    [self bd_downloadImageToCacheForUrl:url options:0];
}
-(void)bd_downloadImageToCacheForUrl:(NSURL *)url options:(SDWebImageOptions)options
{
    [self downloadImageWithURL:url options:options progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
       
        [self.imageCache storeImage:image forKey:[self cacheKeyForURL:url]];
    }];
}
-(void)bd_downloadImageToCacheForUrlInWiFi:(NSURL *)url options:(SDWebImageOptions)options
{
    //如果wifi环境下 进行下载
    [self bd_downloadImageToCacheForUrl:url options:options];
}


#pragma mark-自定义存储类型
-(void)bd_saveImageToCache:(UIImage *)image forUrl:(NSURL *)url type:(BDCacheKeyType)type
{
    [self bd_saveImageToCache:image forKey:[self bd_cacheKeyForUrl:url type:type]];
}
-(UIImage *)bd_cacheImageForUrl:(NSURL *)url type:(BDCacheKeyType)type
{
    return [self bd_cacheImageForKey:[self bd_cacheKeyForUrl:url type:type]];
}
-(void)bd_diskImageExistsForUrl:(NSURL *)url type:(BDCacheKeyType)type complete:(SDWebImageCheckCacheCompletionBlock)complete
{
    [self.imageCache diskImageExistsWithKey:[self bd_cacheKeyForUrl:url type:type] completion:complete];
}
-(void)bd_downloadImageToCacheForUrl:(NSURL *)url type:(BDCacheKeyType)type options:(SDWebImageOptions)options
{
    [self downloadImageWithURL:url options:options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
       
        [self.imageCache storeImage:image forKey:[self bd_cacheKeyForUrl:url type:type]];
    }];
}
-(NSString *)bd_cacheKeyForUrl:(NSURL *)url type:(BDCacheKeyType)type
{
    if(self.cacheKeyFilter)
    {
        return self.cacheKeyFilter(url);
    }
    else
    {
        return [[url absoluteString] stringByAppendingString:[self getExtensionStringForType:type]];
    }
}
-(NSString *)getExtensionStringForType:(BDCacheKeyType)type
{
    NSString *string=@"";
    switch (type) {
        case BDCacheKeyType_Avatar:
            string=@"_avatar";
            break;
        case BDCacheKeyType_AvatarWithBorder:
            string=@"_avatar_border";
            break;
        case BDCacheKeyType_Content:
            string=@"_avatar_content";
            break;
        case BDCacheKeyType_Help:
            string=@"_help";
            break;
        default:
            string=@"";
            break;
    }
    return string;
}







@end
