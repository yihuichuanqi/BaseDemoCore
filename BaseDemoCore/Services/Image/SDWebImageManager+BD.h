//
//  SDWebImageManager+BD.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*扩展SDWebImageManager 并且添加自定义图片存储类型*/

#import <SDWebImage/SDWebImageManager.h>

typedef NS_ENUM(NSUInteger,BDCacheKeyType) {
    
    BDCacheKeyType_Default=0,
    BDCacheKeyType_Avatar,//圆形头像
    BDCacheKeyType_AvatarWithBorder,//带边框的头像
    BDCacheKeyType_Content,//内容经过压缩
    BDCacheKeyType_Help,//辅助图片（通过绘制生成）
};

@interface SDWebImageManager (BD)

#pragma mark-扩展SDWebImage
//缓存图片
-(void)bd_saveImageToCache:(UIImage *)image forKey:(NSString *)cacheKey;
//获取缓存图片
-(UIImage *)bd_cacheImageForKey:(NSString *)cacheKey;
-(UIImage *)bd_cacheImageForKey:(NSString *)cacheKey cahceType:(SDImageCacheType *)cacheType;
//根据url缓存图片
-(void)bd_saveImageToCacheIfNotExist:(UIImage *)image forUrl:(NSURL *)url;
//获取
-(UIImage *)bd_cacheImageForUrl:(NSURL *)url;
-(UIImage *)bd_cacheImageForUrl:(NSURL *)url cacheType:(SDImageCacheType *)cacheType;

//下载图片
-(void)bd_downloadImageToCacheForUrl:(NSURL *)url;
-(void)bd_downloadImageToCacheForUrl:(NSURL *)url options:(SDWebImageOptions)options;
//wifi环境下下载图片
-(void)bd_downloadImageToCacheForUrlInWiFi:(NSURL *)url options:(SDWebImageOptions)options;

//自定义图片类型
-(void)bd_saveImageToCache:(UIImage *)image forUrl:(NSURL *)url type:(BDCacheKeyType)type;
-(UIImage *)bd_cacheImageForUrl:(NSURL *)url type:(BDCacheKeyType)type;
-(void)bd_diskImageExistsForUrl:(NSURL *)url type:(BDCacheKeyType)type complete:(SDWebImageCheckCacheCompletionBlock)complete;
-(void)bd_downloadImageToCacheForUrl:(NSURL *)url type:(BDCacheKeyType)type options:(SDWebImageOptions)options;
-(NSString *)bd_cacheKeyForUrl:(NSURL *)url type:(BDCacheKeyType)type;



@end
