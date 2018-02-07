//
//  BDImageLoader.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*自定义预览图管理类*/

#import <Foundation/Foundation.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface BDImageLoader : NSObject

//存储预览图（小图）key
@property (nonatomic,strong) NSCache<NSURL *,NSURL *> *previewImageUrlCache;

+(instancetype)sharedLoader;

//获取本地图片 适用于配置文件 在不配置文件时充mainBundle中读取
-(UIImage *)getLocalImageWithPath:(NSString *)imagePath;
-(UIImage *)getPackageImageWithPath:(NSString *)imagePath;
-(void)checkPackageImageWithPath:(NSString *)imagePath;

//上传图片(暂未实现)
-(void)uploadImage:(UIImage *)image complete:(void(^)(NSURL *url,NSString *cacheKey,NSError *error))complete;
//获取附带尺寸的图片Url（preferSize需求尺寸 会自动根据屏幕scale放大 类似x2、x3）
-(NSURL *)imageUrl:(NSURL *)originUrl withPreferSize:(CGSize)preferSize;

@end

//扩展 UIImageView控件加载图片
@interface UIImageView (BDImageLoader)

-(void)bd_setLocalImagePath:(NSString *)imagePath;
-(void)bd_setImageWithUrl:(NSURL *)url preferSize:(CGSize)preferSize;
-(void)bd_setImageWithUrl:(NSURL *)url preferSize:(CGSize)preferSize placeholderImage:(UIImage *)placeholder;
-(void)bd_setImageWithUrl:(NSURL *)url preferSize:(CGSize)preferSize placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlcok;
-(void)bd_setImageWithUrl:(NSURL *)url preferSize:(CGSize)preferSize placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlcok;
-(void)bd_setImageWithUrl:(NSURL *)url preferSize:(CGSize)preferSize placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlcok;
@end




