//
//  UITableView+BDEmptyTable.h
//  BaseDemoCore
//
//  Created by Admin on 2017/12/28.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BDEmptyDataView;

typedef NS_ENUM(NSInteger,BDEmptyDataStyle) {
    
    BDEmptyDataStyle_None, //关闭此功能
    BDEmptyDataStyle_Default, //使用默认视图
    BDEmptyDataStyle_DIY, //自定义视图 如果视图为nil 则使用默认
};

//默认Style
extern BDEmptyDataStyle BD_DefaultStyle;
typedef void (^BDDiyViewShowBlock)(void);

@interface UITableView (BDEmptyTable)

@property (nonatomic,assign) BDEmptyDataStyle bd_NoDataStyle;

//仅在BDEmptyDataStyle_DIY生效 布局自定义
@property (nonatomic,strong) UIView *bd_DiyView;
@property (nonatomic,copy) BDDiyViewShowBlock diyBlock;

//是否显示无数据视图 仅在非BDEmptyDataStyle_None并且bd_IsManualShow==Yes生效
@property (nonatomic,assign) BOOL bd_ShowNoDataView;
//是否手动显示无数据视图 默认NO
@property (nonatomic,assign) BOOL bd_IsManualShow;

@property (nonatomic,strong,readonly) BDEmptyDataView *bd_DefaultView;
@end

@interface UIScrollView (BDEmpty)

-(void)bd_SetContentSize:(CGSize)contentSize;
@end



//列表为空 默认视图
@interface BDEmptyDataView : UIView

//可重新刷新视图数据
-(void)refreshEmptyView;
@end
