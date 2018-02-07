//
//  UIImage+BD.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/29.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BD)

+(UIImage *)bd_imageFromColor:(UIColor *)color;
-(UIImage *)bd_imageTintedWithColor:(UIColor *)color;
-(UIImage *)bd_imageTintedWithColor:(UIColor *)color traction:(CGFloat)fraction;


//纠正图片方向（确保图片朝上）
-(UIImage *)bd_fixOrientation;

// 兼容系统版本的resizableImageWithCapInsets:函数
// 低于IOS5则只有capInsets.left capInsets.top生效
-(UIImage *)bd_resizeableImageWithCapInset_x:(UIEdgeInsets)capInsets;
+(UIImage *)bd_resizeableImageNamed:(NSString *)name capLeft:(CGFloat)left capTop:(CGFloat)top;
//支持部队称图片的自动拉伸 低于ios5则只有capInsets.left capInsets.top生效（推荐使用）
+(UIImage *)bd_resizeableImageNamed:(NSString *)name capInset:(UIEdgeInsets)capInsets;



//上下左右完全堆成图片自动拉伸
+(UIImage *)bd_resizeableImage:(NSString *)name;
-(UIImage *)bd_boxblurImageWithBlur:(CGFloat)blur;

//图片压缩
-(UIImage *)bd_compressdImage;
-(NSData *)bd_compressdImageData;
-(UIImage *)bd_particalImageWithPercentage:(CGFloat)percentage vertical:(BOOL)vertical grayscaleRest:(BOOL)grayscaleRest;
-(UIImage *)bd_grayscaleImage;


//图片模糊效果
-(UIImage *)bd_applyLightEffect;
-(UIImage *)bd_applyExtraLightEffect;
-(UIImage *)bd_applyDarkEffect;
-(UIImage *)bd_applyTintEffectWithColor:(UIColor *)tintColor;
-(UIImage *)bd_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskIMage:(UIImage *)maskImage;
-(UIImage *)bd_imageByRotatingImage:(UIImage *)image fromImageOrientation:(UIImageOrientation)orientation;
+(CGImageRef)bd_CGImageRotatedByAngle:(CGImageRef)imageRef angle:(CGFloat)angle;

//根据图片大小 计算得到上传时压缩的大小
+(CGFloat)bd_caculateUploadImageFileSize:(CGSize)imageSize;
//获取fit的Size 即最大宽高
+(CGSize)bd_caculatePHRequestImageSize:(CGSize)imageSize;
//改变图片尺寸（内存使用大大低于UIGraphicsBeginImageContext）
+(UIImage *)bd_resizeImageFromJPEGData:(NSData *)jpegData maxValue:(CGFloat)max;
-(UIImage *)bd_imageWithSize:(CGSize)size radius:(int)radius;



@end
