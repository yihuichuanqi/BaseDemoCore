//
//  UIImageView+BDAvartar.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/29.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*用于定制用户头像圆角图片*/

#import <UIKit/UIKit.h>

@interface UIImageView (BDAvartar)


-(void)bd_setAvartarForUrl:(NSURL *)url;
-(void)bd_setAvartarForUrl:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;
-(void)bd_setContentImageForUrl:(NSURL *)url placeholderImage:(UIImage *)placeholderImage size:(CGSize)size;

@end
