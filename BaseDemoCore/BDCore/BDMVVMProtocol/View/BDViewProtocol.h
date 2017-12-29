//
//  BDViewProtocol.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/29.
//  Copyright © 2017年 Admin. All rights reserved.
//

/*
 *为View绑定方法协议
 */

#import <Foundation/Foundation.h>

@protocol BDViewProtocol <NSObject>

@required
//初始化额外数据
-(void)bd_initialExtraDataForView;
//创建视图
-(void)bd_setupViewForView;

//绑定VM
-(void)bd_bindViewModel:(id<BDViewProtocol>)viewModel withParams:(NSDictionary *)params;

@end
