//
//  UIImageView+BDWebImageCacheEx.h
//  BaseDemoCore
//
//  Created by scl on 2018/1/24.
//  Copyright © 2018年 Admin. All rights reserved.
//

/*扩展UIImageView 实现网络图片加载失败显示占位图片 */

#import <UIKit/UIKit.h>

@interface UIImageView (BDWebImageCacheEx)

@property (nonatomic,assign) IBInspectable BOOL bd_useDefaultPlaceholder; //是否使用默认占位图
@property (nonatomic,assign) IBInspectable BOOL bd_handleLoadFail; //是否处理加载失败情况
@property (nonatomic,strong,setter=bd_setLoadFailImage:) UIImage *bd_loadFailImage; //错误图片
@property (nonatomic,readonly) UIView *bd_DefaultPlaceholderView;


//IBInspectable 属性不能使用setter重命名set方法名，否则使用了该属性的xib会报找不到属性
-(void)bd_setUseDefaultPlaceholder:(BOOL)useDefaultPlaceholder;
-(void)bd_setHandleLoadFail:(BOOL)handleLoadFail;

//未实现
@property (nonatomic,copy,setter=bd_setLastLoadUrl:) NSURL *bd_lastLoadUrl;
//@property (nonatomic,copy) void (^reloadHandler) (UIImageView *imageView);


@end
