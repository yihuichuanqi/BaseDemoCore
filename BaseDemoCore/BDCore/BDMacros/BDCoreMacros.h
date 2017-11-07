//
//  BDCoreMacros.h
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#ifndef BDCoreMacros_h
#define BDCoreMacros_h

//中文字体
#define Chinese_Font_Name @"Heiti SC"
#define Chinese_System(x) [UIFont fontWithName:Chinese_Font_Name size:x]
#define BoldSystemFont(fontSize) [UIFont boldSystemFontOfSize:fontSize]
#define SystemFont(fontSize) [UIFont systemFontOfSize:fontSize]
#define Font(name,fontSize) [UIFont fontWithName:(name) size:(fontSize)]

//不同屏幕尺寸字体适配(320,568只是因为效果图为IPhone5，可根据实际情况设置修改)
#define kScreenWidthRatio

//主屏幕
#define Main_Screen_Height [[UIScreen mainScreen] bounds].size.height
#define Main_Screen_Width  [[UIScreen mainScreen] bounds].size.width
#define Main_screen_Bounds [[UIScreen mainScreen] bounds]

//App Frame
#define App_Frame_Height [UIScreen bounds].size.height
#define App_Frame_Width  [UIScreen bounds].size.width

//view属性
#define GetViewWidth(view) view.frame.size.width
#define GetViewHeight(view) view.frame.size.height
#define GetViewX(view) view.frame.origin.x
#define GetViewY(view) view.frame.origin.y

//系统版本判断
#define isIOS9 ([[[UIDevice currentDevice]systemVersion]floatValue] >= 9.0)
#define isIOS8 ([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0)
#define isIOS7 ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
#define isIOS6 ([[[UIDevice currentDevice]systemVersion]floatValue] < 7.0)

//角度弧度互转
#define kDegreesToRadian(x) (M_PI*(x)/180.0)
#define kRadianToDegress(radian) (radian*180.0)/(M_PI)

//颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)
#define HEXColor(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]
#define Color_RGB(rgbValue,a) [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((float)(((rgbValue) & 0xFF00)>>8))/255.0 blue: ((float)((rgbValue) & 0xFF))/255.0 alpha:(a)]


#endif /* BDCoreMacros_h */
