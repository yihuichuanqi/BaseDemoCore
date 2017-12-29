//
//  UIViewController+BDAutoEmptyView.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/28.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (BDAutoEmptyView)

//列表页面为空时的页面
-(UIView *)BD_AutoEmptyPlaceHolderViewForViewController;
//展示空页面时
-(BOOL)BD_AutoEmptyEnableTableScrollForController;
@end
