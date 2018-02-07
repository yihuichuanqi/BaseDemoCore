//
//  BDImageUrl.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*用于应用图片模型转化*/

#import "BDBaseModelObject.h"

@interface BDImageUrl : BDBaseModelObject

//不同尺寸图片链接
@property (nonatomic,copy,readonly) NSString *urlForOriginal;
@property (nonatomic,copy,readonly) NSString *urlForMedium;
@property (nonatomic,copy,readonly) NSString *urlFoSmall;
@property (nonatomic,assign,readonly) CGFloat width;
@property (nonatomic,assign,readonly) CGFloat height;

@property (nonatomic,copy) NSString *imageId;
@property (nonatomic,copy) NSString *imageUrl;


-(instancetype)initWithUrl:(NSURL *)imageUrl;
-(instancetype)initWithUrlString:(NSString *)imageUrlString;
//使用UIImage构造，imageUrl随机生成 图片直接设置到Url对应的缓存中
+(instancetype)imageUrlWithPreviewImage:(UIImage *)previewImage;
//如果为YES 则中、小图片与原图一致
-(id)initWithAttributes:(NSDictionary *)aAttributes forLocalImage:(BOOL)isLocalImage;

//更新自身的图片cache 如果已经缓存在不更新
-(void)updateCacheImageWithPreviewImageUrl:(BDImageUrl *)previewImageUrl;
-(void)updateCacheImageWithPreviewImage:(UIImage *)previewImage;



@end
