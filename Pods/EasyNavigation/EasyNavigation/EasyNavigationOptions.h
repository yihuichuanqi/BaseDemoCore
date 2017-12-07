//
//  EasyNavigationOptions.h
//  EasyNavigationDemo
//
//  Created by Mr_Chen on 17/9/11.
//  Copyright © 2017年 chenliangloveyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface EasyNavigationOptions : NSObject

/**
 * 导航条基本设置的单例，用来设置全局导航条属性。(当需要改变导航条属性时，需要对改变的导航条单独设置)
 * 只需在APPdelegate里面设置一次，全局适用。
 */
+ (instancetype)shareInstance ;

/**
 * 导航条的透明度
 */
@property (nonatomic,assign)CGFloat backGroundAlpha ;

/**
 * 导航条的背景色
 */
@property (nonatomic,strong)UIColor *navBackGroundColor ;

/**
 * 导航条细线下的颜色
 */
@property (nonatomic,strong)UIColor *navLineColor ;

/**
 * 导航条的背景图片
 */
@property (nonatomic,strong)UIImage *navBackgroundImage ;


/**
 * titleLabel 字体大小
 */
@property (nonatomic,strong)UIFont  *titleFont ;
/**
 * titleLabel 字体颜色
 */
@property (nonatomic,strong)UIColor *titleColor ;


/**
 * 左右两边按钮字体大小
 */
@property (nonatomic,strong)UIFont  *buttonTitleFont ;

/**
 * 按钮字体颜色
 */
@property (nonatomic,strong)UIColor *buttonTitleColor ;

/**
 * 按钮高亮时的字体颜色
 */
@property (nonatomic,strong)UIColor *buttonTitleColorHieght ;


@end
