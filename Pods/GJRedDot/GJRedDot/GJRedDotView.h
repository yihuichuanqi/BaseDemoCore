//
//  GJRedDotView.h
//  GJRedDotDemo
//
//  Created by wangyutao on 16/5/24.
//  Copyright © 2016年 wangyutao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GJRedDotView : UIImageView

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) CGFloat borderWidth;

@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, assign) CGPoint offset;

@property (nonatomic, copy) void (^refreshBlock)(GJRedDotView *view);

+ (void)setDefaultRadius:(CGFloat)radius;

+ (void)setDefaultColor:(UIColor *)color;

@end


@interface GJBadgeView : UIImageView

@property (nonatomic, copy) NSString *badgeValue;

@property (nonatomic, assign) CGPoint offset;

@property (nonatomic, strong) UIColor *color;

@end
