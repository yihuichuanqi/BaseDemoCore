//
//  BDTableViewPlaceHolderDelegate.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/28.
//  Copyright © 2017年 Admin. All rights reserved.
//


#import <Foundation/Foundation.h>


@protocol BDTableViewPlaceHolderDelegate <NSObject>

@required
//列表页面为空时的页面
- (UIView *)BD_AutoEmptyPlaceholderView;
@optional
//展示空页面时 列表是否可滚动（默认为NO 不需设置 若添加 则会崩溃）
- (BOOL)BD_AutoEmptyEnableTableViewScroll;


@end
