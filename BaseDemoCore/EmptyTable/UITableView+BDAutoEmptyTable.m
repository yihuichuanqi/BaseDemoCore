//
//  UITableView+BDAutoEmptyTable.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/28.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "UITableView+BDAutoEmptyTable.h"
#import "BDMethodSwizzingUtil.h"
#import "UIViewController+BDAutoEmptyView.h"
#import "BDTableViewPlaceHolderDelegate.h"

@interface UITableView ()

@property (nonatomic,strong) UIView *placeHolderView;
@property (nonatomic,assign) BOOL isFirstReloaded; //判断是否首次加载
@property (nonatomic,assign) BOOL scrollWasEnabled; //是否可滚动
@end


@implementation UITableView (BDAutoEmptyTable)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [BDMethodSwizzingUtil swizzinClass:[self class] OriginalSEL:@selector(reloadData) TonewSEL:@selector(bd_SwizzReloadData)];
    });
}
#pragma mark-方法一
-(void)bd_SwizzReloadData
{
    [self bd_SwizzReloadData];
    [self checkTableDataEmptyWithController];
}
//通过视图控制器代理
-(void)checkTableDataEmptyWithController
{
    if (self.isFirstReloaded)
    {
        return;
    }
    self.isFirstReloaded=NO;
    
    UIView *tempPlaceHolderView=[self.superViewControllerDelegate BD_AutoEmptyPlaceHolderViewForViewController];
    if (!tempPlaceHolderView)
    {
        return;
    }
    BOOL enableScroll=[self.superViewControllerDelegate BD_AutoEmptyEnableTableScrollForController];
    BOOL isEmpty=[self isTableEmpty];
    if (isEmpty)
    {
        [self.placeHolderView removeFromSuperview];
        self.placeHolderView=nil;
        self.placeHolderView=tempPlaceHolderView;
        tempPlaceHolderView.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.placeHolderView];
        self.scrollEnabled=enableScroll;
    }
    else
    {
        [self.placeHolderView removeFromSuperview];
        self.placeHolderView=nil;
        self.scrollEnabled=YES;
    }
}

#pragma mark-方法二
-(void)bd_ReloadTableData
{
    [self reloadData];
    [self checkTableDataEmptyWithReloadData];
}
-(void)checkTableDataEmptyWithReloadData
{
//    *不同状态
//    *相等 （view存在 empty为空）、（view不存在 empty不为空）
//    *不相等 （view存在 empty不为空）、（view不存在 empty为空）
    BOOL isEmpty=[self isTableEmpty];
    if(!isEmpty!=!self.placeHolderView)
    {
        if (isEmpty)
        {
            self.scrollWasEnabled=self.scrollEnabled;
            BOOL scrollEnabled=[self tempScrollEnableable];
            self.scrollEnabled=scrollEnabled;
            self.placeHolderView=[self tempPlaceHolderView];
            [self addSubview:self.placeHolderView];
        }
        else
        {
            self.scrollEnabled=self.scrollWasEnabled;
            [self.placeHolderView removeFromSuperview];
            self.placeHolderView=nil;
        }
    }
    else
    {
        //为规避空页面状态不刷新 需先移除置nil 每次都使用新的类
        if (self.placeHolderView)
        {
            [self.placeHolderView removeFromSuperview];
            self.placeHolderView=nil;
        }
        self.placeHolderView=[self tempPlaceHolderView];
        [self addSubview:self.placeHolderView];
    }
}

-(BOOL)tempScrollEnableable
{
    BOOL scrollEnabled=NO;
    if ([self respondsToSelector:@selector(BD_AutoEmptyEnableTableViewScroll)])
    {
        scrollEnabled=[self performSelector:@selector(BD_AutoEmptyEnableTableViewScroll)];
        if (!scrollEnabled)
        {
            //不滚动的话 则无需设置
            NSString *reason=@"There no need return NO,It will be No by defaults";
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
    }
    else if ([self.delegate respondsToSelector:@selector(BD_AutoEmptyEnableTableViewScroll)])
    {
        scrollEnabled=[self.delegate performSelector:@selector(BD_AutoEmptyEnableTableViewScroll)];
        if (!scrollEnabled)
        {
            //不滚动的话 则无需设置
            NSString *reason=@"There no need return NO,It will be No by defaults";
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
    }
    return scrollEnabled;

}
-(UIView *)tempPlaceHolderView
{
    UIView *tempVV;
    if ([self respondsToSelector:@selector(BD_AutoEmptyPlaceholderView)])
    {
        tempVV=[self performSelector:@selector(BD_AutoEmptyPlaceholderView)];
    }
    else if ([self.delegate respondsToSelector:@selector(BD_AutoEmptyPlaceholderView)])
    {
        tempVV=[self.delegate performSelector:@selector(BD_AutoEmptyPlaceholderView)];
    }
    else
    {
        NSString *selectName=NSStringFromSelector(_cmd);
        NSString *reason=[NSString stringWithFormat:@"You Must Implemeny PlaceHolderView If You Want To Use %@",selectName];
        @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
    }
    tempVV.frame=self.bounds;
    return tempVV;
    
}

#pragma mark-Private
//是否是空页面
-(BOOL)isTableEmpty
{
    BOOL isEmpty=YES;
    id<UITableViewDataSource> src=self.dataSource;
    NSInteger sections=1;
    if ([src respondsToSelector:@selector(numberOfSectionsInTableView:)])
    {
        sections=[src numberOfSectionsInTableView:self];
    }
    for (int index=0; index<sections; index++)
    {
        NSInteger row=[src tableView:self numberOfRowsInSection:sections];
        if (row)
        {
            isEmpty=NO;
            break;
        }
    }
    return isEmpty;
}

#pragma mark-set get
-(UIView *)placeHolderView
{
    return objc_getAssociatedObject(self, @selector(placeHolderView));
}
-(void)setPlaceHolderView:(UIView *)placeHolderView
{
    objc_setAssociatedObject(self, @selector(placeHolderView), placeHolderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIViewController *)superViewControllerDelegate
{
    return objc_getAssociatedObject(self, @selector(superViewControllerDelegate));

}
-(void)setSuperViewControllerDelegate:(UIViewController *)superViewControllerDelegate
{
    objc_setAssociatedObject(self, @selector(superViewControllerDelegate), superViewControllerDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}
-(BOOL)scrollWasEnabled
{
    return [objc_getAssociatedObject(self, @selector(scrollWasEnabled)) boolValue];

}
-(void)setScrollWasEnabled:(BOOL)scrollWasEnabled
{
    objc_setAssociatedObject(self, @selector(scrollWasEnabled), @(scrollWasEnabled), OBJC_ASSOCIATION_ASSIGN);

}

-(BOOL)isFirstReloaded
{
    return [objc_getAssociatedObject(self, @selector(isFirstReloaded)) boolValue];

}
-(void)setIsFirstReloaded:(BOOL)isFirstReloaded
{
    objc_setAssociatedObject(self, @selector(isFirstReloaded), @(isFirstReloaded), OBJC_ASSOCIATION_ASSIGN);

}

@end
