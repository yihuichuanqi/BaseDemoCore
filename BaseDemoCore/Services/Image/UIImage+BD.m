//
//  UIImage+BD.m
//  BaseDemoCore
//
//  Created by scl on 2018/1/29.
//  Copyright © 2018年 Admin. All rights reserved.
//

#import "UIImage+BD.h"

@implementation UIImage (BD)

+(UIImage *)bd_imageFromColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context=UIGraphicsGetCurrentContext();
    //填充颜色
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
-(UIImage *)bd_imageTintedWithColor:(UIColor *)color
{
    return [self bd_imageTintedWithColor:color traction:0.0];
}
-(UIImage *)bd_imageTintedWithColor:(UIColor *)color traction:(CGFloat)fraction
{
    if (color)
    {
        UIImage *image;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

        if ([[[UIDevice currentDevice]systemVersion] floatValue]>=4.0)
        {
            UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0);
        }
#else
        if ([[[UIDevice currentDevice]systemVersion] floatValue]<4.0)
        {
            UIGraphicsBeginImageContext([self size]);
        }
        
#endif
        
        CGRect rect=CGRectZero;
        rect.size=[self size];
        //填充
        [color set];
        UIRectFill(rect);
        [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
        if (fraction>0.0)
        {
            [self drawInRect:rect blendMode:kCGBlendModeSourceAtop alpha:fraction];
        }
        image=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
        
    }
    return self;
}

-(UIImage *)bd_fixOrientation
{
    
    if (self.imageOrientation==UIImageOrientationUp)
    {
        return self;
    }
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform=CGAffineTransformIdentity;
    //第一步 旋转
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
        {
            //方向朝下 则XY方向缩放宽高、旋转180度
            transform=CGAffineTransformTranslate(transform, self.size.width, self.size.height);//对要进行变换的矩阵 进行缩放倍数
            transform=CGAffineTransformRotate(transform, M_PI);
        }
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        {
            //方向朝左 则X方向缩放
            transform=CGAffineTransformScale(transform, self.size.width, 0);
            transform=CGAffineTransformRotate(transform, M_PI_2);
        }
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            transform=CGAffineTransformScale(transform, 0, self.size.height);
            transform=CGAffineTransformRotate(transform, -M_PI_2);
        }
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
        default:
            break;
    }
    //第二步
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            {
                transform=CGAffineTransformTranslate(transform, self.size.width, 0);
                transform=CGAffineTransformScale(transform, -1, 1);
            }
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
        {
            transform=CGAffineTransformTranslate(transform, self.size.height, 0);
            transform=CGAffineTransformScale(transform, -1, 1);

        }
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
            
        default:
            break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx=CGBitmapContextCreate(NULL, self.size.width, self.size.height, CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgImg=CGBitmapContextCreateImage(ctx);
    UIImage *img=[UIImage imageWithCGImage:cgImg];
    CGContextRelease(ctx);
    CGImageRelease(cgImg);
    return img;
}

+(CGFloat)bd_caculateUploadImageFileSize:(CGSize)imageSize
{
    //配置参数
    CGFloat maxWidth=1080.0;
    CGFloat maxHeight=1920.0;
    CGFloat standSize=maxWidth*maxHeight;
    CGFloat targetSize=400.0*1024.0;
    CGFloat rate=maxWidth*maxHeight/targetSize;
    //图片大小
    CGFloat imageWidth=imageSize.width;
    CGFloat imageHeight=imageSize.height;
    //图片像素
    CGFloat pixel=imageWidth*imageHeight;
    if(pixel>standSize)
    {
        targetSize=pixel/rate;
    }
    if (targetSize>2*1024*1024)
    {
        targetSize=2*1024*1024;
    }
    return targetSize;
}
+(CGSize)bd_caculatePHRequestImageSize:(CGSize)imageSize
{
    CGFloat maxWidth=1080.0;
    CGFloat maxHeight=1920.0;
    //控制在max范围内的图片比例压缩
    CGSize targetSize=CGSizeMake(maxWidth, maxHeight);
    CGRect screenRect=[[UIScreen mainScreen] bounds];
    CGFloat screenRate=screenRect.size.height/screenRect.size.width;
    CGFloat imageWidth=imageSize.width;
    CGFloat imageHeight=imageSize.height;
    if (imageHeight>=imageWidth)
    {
        //图片高度>=宽度
        CGFloat rate=(imageHeight/imageWidth);
        if (rate>screenRate*1.5)
        {
            if (imageWidth>maxWidth)
            {
                //大分辨率图片 获取压缩到最大宽度 的图片
                targetSize=CGSizeMake(maxWidth, imageHeight*maxWidth/imageWidth);
            }
            else
            {
                //细长图片 去原图坐标
                targetSize=CGSizeMake(imageWidth, imageHeight);
            }
        }
        else
        {
            //长宽比例正常
            targetSize=CGSizeMake(maxWidth, maxHeight);
        }
    }
    else
    {
        //图片宽度>高度
        CGFloat rate=(imageWidth/imageHeight);
        if (rate>screenRate*1.5)
        {
            if (imageHeight>maxHeight)
            {
                //大分辨率图片 获取压缩到最大高度的图片
                targetSize=CGSizeMake(maxWidth*maxHeight/imageHeight, imageHeight);
            }
            else
            {
                //细宽图片 取原图坐标
                targetSize=CGSizeMake(imageWidth, imageHeight);
            }
        }
        else
        {
            //长宽比例正常
            targetSize=CGSizeMake(maxWidth, maxHeight);
        }
    }
    return targetSize;
}

+(UIImage *)bd_resizeImageFromJPEGData:(NSData *)jpegData maxValue:(CGFloat)max
{
    CGImageRef thumbnailCGImage=NULL;
    CGDataProviderRef provider=CGDataProviderCreateWithCFData((__bridge CFDataRef)jpegData);
    if (provider)
    {
        CGImageSourceRef imageSource=CGImageSourceCreateWithDataProvider(provider, NULL);
        if (imageSource)
        {
            if (CGImageSourceGetCount(imageSource)>0)
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
-(UIImage *)bd_imageWithSize:(CGSize)size radius:(int)radius
{
    //扩大至2倍图
    size=CGSizeMake(size.width*2, size.height*2);
    radius=radius*2;
    
    UIImage *img=self;
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef context=CGBitmapContextCreate(NULL, size.width, size.height, 8, 4*size.width, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect=CGRectMake(0, 0, size.width, size.height);
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, radius, radius);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), img.CGImage);
    CGImageRef imageMasked=CGBitmapContextCreateImage(context);
    img=[UIImage imageWithCGImage:imageMasked];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    return img;
}



#pragma mark-C 方法
//获取圆角区域
static void addRoundedRectToPath(CGContextRef context,CGRect rect, float ovalWidth,float ovalHeight)
{
    float fw,fh;
    if (ovalWidth==0||ovalHeight==0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw=CGRectGetWidth(rect)/ovalWidth;
    fh=CGRectGetHeight(rect)/ovalHeight;
    
    // Start at lower right corner
    CGContextMoveToPoint(context, fw, fh/2);
    // Top right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    //Top left corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    //Lower left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    //Back to lower right
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);

    
}







@end
