//
//  BDViewControllerProtocol.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/29.
//  Copyright © 2017年 Admin. All rights reserved.
//

/*
 *为ViewController 绑定方法协议
 */

#import <Foundation/Foundation.h>

@protocol BDViewControllerProtocol <NSObject>

@required
//初始化数据
-(void)bd_initialDefaultsForController;
//绑定VM
-(void)bd_bindViewModelForController;
//创建视图
-(void)bd_setupViewForController;

@optional
//配置导航栏
-(void)bd_configNavgationForController;

@end
