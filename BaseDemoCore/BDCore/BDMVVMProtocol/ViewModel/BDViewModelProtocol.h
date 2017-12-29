//
//  BDViewModelProtocol.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/29.
//  Copyright © 2017年 Admin. All rights reserved.
//

/*
 *为ViewModel绑定方法协议
 */

#import <Foundation/Foundation.h>

@protocol BDViewModelProtocol <NSObject>

@required
//初始化属性
-(void)bd_initialDataForViewModel;

@end
