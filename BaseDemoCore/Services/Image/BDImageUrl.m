//
//  BDImageUrl.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "BDImageUrl.h"
#import "NSDictionary+BD.h"
#import "NSURL+BD.h"
#import "SDWebImageManager+BD.h"

@implementation BDImageUrl

-(instancetype)initWithUrl:(NSURL *)imageUrl
{
    return [self initWithUrlString:[imageUrl absoluteString]];
}
-(instancetype)initWithUrlString:(NSString *)imageUrlString
{
    if (self=[super init])
    {
        //默认彼此相同
        _urlForOriginal=imageUrlString;
        _urlForMedium=_urlForOriginal;
        _urlFoSmall=_urlForOriginal;
    }
    return self;
}

-(id)initWithAttributes:(NSDictionary *)aAttributes
{
    return [self initWithAttributes:aAttributes forLocalImage:NO];
}
-(NSDictionary *)attributesFromModel
{
    NSMutableDictionary *dict=[[super attributesFromModel] mutableCopy];
    [dict bd_safeSetObject:self.imageUrl forKey:@"imageUrl"];
    [dict bd_safeSetObject:@(self.width) forKey:@"width"];
    [dict bd_safeSetObject:@(self.height) forKey:@"height"];
    [dict bd_safeSetObject:self.imageId forKey:@"imageId"];
    return [dict copy];
}

-(id)initWithAttributes:(NSDictionary *)aAttributes forLocalImage:(BOOL)isLocalImage
{
    if (self=[super initWithAttributes:aAttributes])
    {
        NSString *originalUrl=[aAttributes bd_StringObjectForKey:@"imageUrl"];
        _urlForOriginal=originalUrl;
        _imageUrl=_urlForOriginal;
        if (isLocalImage)
        {
            _urlForMedium=_urlForOriginal;
            _urlFoSmall=_urlForOriginal;
        }
        else
        {
            _urlForMedium=_urlForOriginal;
            _urlFoSmall=_urlForOriginal;
        }
        _width=[aAttributes bd_DoubleForKey:@"width"];
        _height=[aAttributes bd_DoubleForKey:@"height"];
        _imageId=[aAttributes bd_StringObjectForKey:@"imageId"];
    }
    return self;
}

+(instancetype)imageUrlWithPreviewImage:(UIImage *)previewImage
{
    if (previewImage==nil)
    {
        return nil;
    }
    NSURL *previewImageUrl=[NSURL bd_AppDomainUrlForPreviewImage];
    NSDictionary *urlValueDic=@{@"imageUrl":previewImageUrl.absoluteString,
                                @"width":@(previewImage.size.width),
                                @"height":@(previewImage.size.height)
                                };
    BDImageUrl *imageUrl=[[BDImageUrl alloc]initWithAttributes:urlValueDic forLocalImage:YES];
    //存储到本地
    [[SDWebImageManager sharedManager] bd_saveImageToCacheIfNotExist:previewImage forUrl:[NSURL URLWithString:imageUrl.urlForOriginal]];
    return imageUrl;
}
-(void)updateCacheImageWithPreviewImageUrl:(BDImageUrl *)previewImageUrl
{
    UIImage *previewImage=[[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:previewImageUrl.urlForOriginal]]];
    [self updateCacheImageWithPreviewImage:previewImage];
}
-(void)updateCacheImageWithPreviewImage:(UIImage *)previewImage
{
    if (previewImage!=nil)
    {
        [[SDWebImageManager sharedManager] bd_saveImageToCacheIfNotExist:previewImage forUrl:[NSURL URLWithString:self.urlForOriginal]];
        [[SDWebImageManager sharedManager] bd_saveImageToCacheIfNotExist:previewImage forUrl:[NSURL URLWithString:self.urlForMedium]];
        [[SDWebImageManager sharedManager] bd_saveImageToCacheIfNotExist:previewImage forUrl:[NSURL URLWithString:self.urlFoSmall]];

    }
}







@end
