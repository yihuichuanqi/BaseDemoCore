//
//  UITableView+BDAutoEmptyTable.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/28.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UITableView (BDAutoEmptyTable)

#pragma mark-两者方法 可二选其一
//需设置此属性(需要重写UIViewController+BDAutoEmptyView的方法)
@property (nonatomic,weak) UIViewController *superViewControllerDelegate;

//需调用此方法 才可生效 (需要遵循BDTableViewPlaceHolderDelegate的方法)
-(void)bd_ReloadTableData;

@end
