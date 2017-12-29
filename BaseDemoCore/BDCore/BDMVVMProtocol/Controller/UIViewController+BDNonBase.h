//
//  UIViewController+BDNonBase.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/29.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (BDNonBase)

//去Model&&表征化参数列表
@property (nonatomic,strong) NSDictionary *params;
@property (nonatomic,strong) id<BDViewControllerProtocol>viewModel;

@end
