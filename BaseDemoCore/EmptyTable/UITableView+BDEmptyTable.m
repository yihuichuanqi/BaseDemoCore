//
//  UITableView+BDEmptyTable.m
//  BaseDemoCore
//
//  Created by Admin on 2017/12/28.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "UITableView+BDEmptyTable.h"
#import "BDMethodSwizzingUtil.h"

//默认
BDEmptyDataStyle BD_DefaultStyle=BDEmptyDataStyle_Default;

const NSString *BD_Key_NoneDataStyle=@"BD_Key_NoneDataStyle";
const NSString *BD_Key_ShowNoneDataView=@"BD_Key_ShowNoneDataView";
const NSString *BD_Key_DefaultView=@"BD_Key_DefaultView";
const NSString *BD_Key_DiyView=@"BD_Key_DiyView";
const NSString *BD_Key_ManualShow=@"BD_Key_ManualShow";
const NSString *BD_Key_AutoShowing=@"BD_Key_AutoShowing";
const NSString *BD_Key_DiyViewBlock=@"BD_Key_DiyViewBlock";


@interface UITableView ()

@property (nonatomic,assign) BOOL isAutoShowing; //记录自动判断是否显示
@end

@implementation UITableView (BDEmptyTable)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [BDMethodSwizzingUtil swizzinClass:[self class] OriginalSEL:@selector(layoutSubviews) TonewSEL:@selector(bd_layoutSubViews)];
        
        [BDMethodSwizzingUtil swizzinClass:[self class] OriginalSEL:@selector(initWithFrame:style:) TonewSEL:@selector(bd_initWithFrame:style:)];
        

    });
    
}

-(void)bd_layoutSubViews
{
    [self bd_layoutSubViews];
    [self bringSubviewToFront:self.bd_DefaultView];
    self.bd_DefaultView.frame=self.bounds;

    if (self.bd_DiyView)
    {
        [self bringSubviewToFront:self.bd_DiyView];
    }
}
-(instancetype)bd_initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    UITableView *tableView=[self bd_initWithFrame:frame style:style];
    tableView.bd_NoDataStyle=BDEmptyDataStyle_Default;
    return tableView;
}


-(void)bd_SetContentSize:(CGSize)contentSize
{
    [super bd_SetContentSize:contentSize];
    BOOL isHavingData=NO;
    NSInteger numberOfSections=[self numberOfSections];
    for (NSInteger i=0; i<numberOfSections; i++)
    {
        if ([self numberOfRowsInSection:i]>0)
        {
            isHavingData=YES;
            break;
        }
    }
    self.isAutoShowing=!isHavingData;
    [self judgeNowStateWithShow:!isHavingData];
}

-(void)judgeNowStateWithShow:(BOOL)show
{
    switch (self.bd_NoDataStyle) {
        case BDEmptyDataStyle_None:
            {
                self.bd_DefaultView.hidden=YES;
                if (self.bd_DiyView)
                {
                    self.bd_DiyView.hidden=YES;
                }
            }
            break;
        case BDEmptyDataStyle_Default:
            {
                if (self.bd_DiyView)
                {
                    self.bd_DiyView.hidden=YES;
                }
                self.bd_DefaultView.hidden=self.bd_IsManualShow?!self.bd_ShowNoDataView:!show;
            }
            break;
        case BDEmptyDataStyle_DIY:
        {
            if (self.bd_DiyView)
            {
                self.bd_DefaultView.hidden=YES;
                self.bd_DiyView.hidden=self.bd_IsManualShow?!self.bd_ShowNoDataView:!show;
            }
            else
            {
                self.bd_DefaultView.hidden=self.bd_IsManualShow?!self.bd_ShowNoDataView:!show;
            }
        }
            break;
            
        default:
            break;
    }
    if (!self.bd_DefaultView.hidden)
    {
        [self.bd_DefaultView refreshEmptyView];
    }
    if (!self.bd_DiyView.hidden)
    {
        if (self.diyBlock)
        {
            self.diyBlock();
        }
    }
    
}

#pragma mark-Set get
-(BDDiyViewShowBlock)diyBlock
{
    return objc_getAssociatedObject(self, (__bridge const void *)(BD_Key_DiyViewBlock));
}

-(void)setDiyBlock:(BDDiyViewShowBlock)diyBlock
{
    objc_setAssociatedObject(self, (__bridge const void *)(BD_Key_DiyViewBlock), diyBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)setBd_DiyView:(UIView *)bd_DiyView
{
    if (self.bd_DiyView)
    {
        [self.bd_DiyView removeFromSuperview];
    }
    [self addSubview:bd_DiyView];
    objc_setAssociatedObject(self, (__bridge const void *)(BD_Key_DiyView), bd_DiyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIView *)bd_DiyView
{
    return objc_getAssociatedObject(self, (__bridge const void *)(BD_Key_DiyView));
}

-(void)setBd_DefaultView:(BDEmptyDataView *)bd_DefaultView
{
    objc_setAssociatedObject(self, (__bridge const void *)(BD_Key_DefaultView), bd_DefaultView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}
-(BDEmptyDataView *)bd_DefaultView
{
    BDEmptyDataView *defaultView=objc_getAssociatedObject(self, (__bridge const void *)(BD_Key_DefaultView));
    if (!defaultView)
    {
        defaultView=[[BDEmptyDataView alloc]init];
        defaultView.hidden=YES;
        [self addSubview:defaultView];
        objc_setAssociatedObject(self, (__bridge const void *)(BD_Key_DefaultView), defaultView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return defaultView;
}

-(void)setBd_NoDataStyle:(BDEmptyDataStyle)bd_NoDataStyle
{
    objc_setAssociatedObject(self, (__bridge const void *)(BD_Key_NoneDataStyle), @(bd_NoDataStyle), OBJC_ASSOCIATION_ASSIGN);
}

-(BDEmptyDataStyle)bd_NoDataStyle
{
    return [objc_getAssociatedObject(self, (__bridge const void *)(BD_Key_NoneDataStyle)) integerValue];
}

-(void)setBd_ShowNoDataView:(BOOL)bd_ShowNoDataView
{
    objc_setAssociatedObject(self, (__bridge const void *)(BD_Key_ShowNoneDataView), @(bd_ShowNoDataView), OBJC_ASSOCIATION_ASSIGN);
    if (self.bd_IsManualShow)
    {
        [self judgeNowStateWithShow:bd_ShowNoDataView];
    }
}
-(BOOL)bd_ShowNoDataView
{
    return [objc_getAssociatedObject(self, (__bridge const void *)(BD_Key_ShowNoneDataView)) boolValue];
}

-(void)setBd_IsManualShow:(BOOL)bd_IsManualShow
{
    objc_setAssociatedObject(self, (__bridge const void *)(BD_Key_ManualShow), @(bd_IsManualShow), OBJC_ASSOCIATION_ASSIGN);
    [self judgeNowStateWithShow:bd_IsManualShow?self.bd_ShowNoDataView:self.isAutoShowing];
}
-(BOOL)bd_IsManualShow
{
    return [objc_getAssociatedObject(self, (__bridge const void *)(BD_Key_ManualShow)) boolValue];
}
-(void)setIsAutoShowing:(BOOL)isAutoShowing
{
    objc_setAssociatedObject(self, (__bridge const void *)(BD_Key_AutoShowing), @(isAutoShowing), OBJC_ASSOCIATION_ASSIGN);
}
-(BOOL)isAutoShowing
{
    return [objc_getAssociatedObject(self, (__bridge const void *)(BD_Key_AutoShowing)) boolValue];
}


@end


@implementation UIScrollView (BDEmpty)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [BDMethodSwizzingUtil swizzinClass:[self class] OriginalSEL:@selector(setContentSize:) TonewSEL:@selector(bd_SetContentSize:)];

    });
}
-(void)bd_SetContentSize:(CGSize)contentSize
{
    [self bd_SetContentSize:contentSize];
}
@end




@interface BDEmptyDataView ()

@property (nonatomic,strong) UILabel *messageLabel;
@end

@implementation BDEmptyDataView


-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        self.backgroundColor=[UIColor groupTableViewBackgroundColor];
    }
    return self;
}
-(UILabel *)messageLabel
{
    if (!_messageLabel)
    {
        _messageLabel=[[UILabel alloc]init];
        _messageLabel.text=@"暂无数据";
        _messageLabel.textColor=[UIColor redColor];
        _messageLabel.font=[UIFont systemFontOfSize:18];
        [self addSubview:_messageLabel];
    }
    return _messageLabel;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.messageLabel sizeToFit];
    self.messageLabel.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

-(void)refreshEmptyView
{
    NSLog(@"页面无网络");
}
@end
