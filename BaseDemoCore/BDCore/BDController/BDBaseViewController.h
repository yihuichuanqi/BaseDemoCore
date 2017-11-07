//
//  BDBaseViewController.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/6.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RealReachability.h"

@protocol BDBaseViewControllerDataSource<NSObject>

@optional

-(NSMutableAttributedString *)setTitle;
-(UIButton *)set_LeftButton;
-(UIButton *)set_RightButton;
//导航栏样式
-(UIColor *)set_ColorBackground;
-(CGFloat) set_NavigationHeight;
-(UIView *)set_BottomView;
-(UIImage *)navBackgroundImage;
-(BOOL)hideNavigationBottomLine;

-(UIImage *)set_LeftBarButtonItemWithImage;
-(UIImage *)set_RightBarButtonItemWithImage;

@end

@protocol BDBaseViewControllerDelegate<NSObject>

-(void)left_Button_Event:(UIButton *)sender;
-(void)right_Button_Event:(UIButton *)sender;
-(void)title_Clicked_Event:(UIView *)sender;


@end

@interface BDBaseViewController : UIViewController<BDBaseViewControllerDelegate,BDBaseViewControllerDataSource>

//页面接收参数
@property (nonatomic,strong) NSDictionary *parameterDictionary;
//初始化参数
-(id)initWithRouterParams:(NSDictionary *)params;

//设置导航栏Y轴
-(void)changeNavigationBarTranslationY:(CGFloat)translationY;
//设置标题
-(void)set_Title:(NSMutableAttributedString *)title;



@end
