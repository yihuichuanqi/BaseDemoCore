//
//  BDTextField.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/15.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDTextField.h"

@interface BDTextField ()


-(UIToolbar *)generateToolBar;
-(void)doneButtonDidPressed:(id)sender;
-(void)notifierKeyBoardWillShow:(NSNotification *)noti;
-(void)notifierKeyBoardWillHide:(NSNotification *)noti;
@end

@implementation BDTextField


-(instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifierKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifierKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.inputAccessoryView=[self generateToolBar];
        self.autocorrectionType=UITextAutocorrectionTypeNo;
        self.placeHolderColor=[UIColor lightGrayColor];
    }
    return self;
}

-(void)setPlaceHolderColor:(UIColor *)placeHolderColor
{
    _placeHolderColor=placeHolderColor;
}
-(void)drawPlaceholderInRect:(CGRect)rect
{
    [_placeHolderColor setFill];
    
    NSMutableParagraphStyle *style=[[NSMutableParagraphStyle alloc]init];
    style.lineBreakMode=NSLineBreakByTruncatingTail;
    style.alignment=self.textAlignment;
    NSDictionary *attri=[NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName,self.font,NSFontAttributeName,self.placeHolderColor,NSForegroundColorAttributeName, nil];
    CGRect bounds=self.bounds;
    CGSize size=[self.placeholder boundingRectWithSize:CGSizeMake(bounds.size.width, bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attri context:nil].size;
    if(self.textAlignment==NSTextAlignmentLeft||self.textAlignment==NSTextAlignmentCenter)
    {
        rect.origin.x=0.0f;
    }
    else if (self.textAlignment==NSTextAlignmentRight)
    {
        rect.origin.x=bounds.size.width-size.width;
    }
    rect.size.width=size.width;
    [[self placeholder] drawInRect:rect withAttributes:attri];
}
//控制placeHolder位置
-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGSize size=[[NSString string] sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.font,NSFontAttributeName, nil]];
    CGRect inset=CGRectMake(bounds.origin.x, 1.0f, bounds.size.width, size.height);
    return inset;
}
-(BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return YES;
}
//禁用粘贴 复制 选择 全选
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action ==@selector(copy:)||action==@selector(paste:)||action==@selector(select:)||action==@selector(selectAll:))
    {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}
-(UIToolbar *)generateToolBar
{
    CGFloat screenWidth=[[UIScreen mainScreen] bounds].size.width;
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    UIBarButtonItem *item1=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *item2=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonDidPressed:)];
    [toolBar setItems:[NSArray arrayWithObjects:item1,item2, nil]];
    return toolBar;
}
-(void)doneButtonDidPressed:(id)sender
{
    [self resignFirstResponder];
}

-(void)notifierKeyBoardWillShow:(NSNotification *)noti
{
    UIView *firstResponder=[UIResponder currentTextFieldFirstResponder];
    if(![firstResponder isEqual:self])
    {
        return;
    }
    UIView *subView=nil;
    if([NSStringFromClass(self.superview.class) isEqualToString:@"UITableViewCellContentView"])
    {
        //确保找到UITableView层次
        subView=self.superview;
        while (subView!=nil)
        {
            if([subView.superview isKindOfClass:[UITableView class]])
            {
                subView=subView.superview;
                break;
            }
            subView=subView.superview;
        }
        UITableView *tableView=(UITableView *)subView;
        
        CGFloat screenHeight=[UIScreen mainScreen].bounds.size.height;
        NSDictionary *info=noti.userInfo;
        CGRect screenFrame=[tableView.superview convertRect:tableView.frame toView:[UIApplication sharedApplication].keyWindow];
        CGFloat tableViewBottomOnScreen=screenFrame.origin.y+screenFrame.size.height;
        CGFloat tableViewGap=screenHeight-tableViewBottomOnScreen;
        CGSize keyboardSize=[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        UIEdgeInsets contentInsets=tableView.contentInset;
        contentInsets.bottom=keyboardSize.height-tableViewGap;
        
        CGFloat animationDuration=((NSNumber *)[info objectForKey:UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
        NSUInteger animationCurve=((NSNumber *)[info objectForKey:UIKeyboardAnimationCurveUserInfoKey]).intValue;
        
        [UIView animateWithDuration:animationDuration delay:0 options:animationCurve animations:^{
            tableView.contentInset=contentInsets;
            tableView.scrollIndicatorInsets=contentInsets;
        } completion:nil];
    }
    
    
}
-(void)notifierKeyBoardWillHide:(NSNotification *)noti
{
    UIView *subView=nil;
    if([NSStringFromClass(self.superview.class) isEqualToString:@"UITableViewCellContentView"])
    {
        subView=self.superview;
        while (subView!=nil)
        {
            if([subView.superview isKindOfClass:[UITableView class]])
            {
                subView=subView.superview;
                break;
            }
            subView=subView.superview;
        }
        
        UITableView *tableView=(UITableView *)subView;
        NSDictionary *info=noti.userInfo;
        CGFloat animationDuration=((NSNumber *)[info objectForKey:UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
        CGFloat animationCurve=((NSNumber *)[info objectForKey:UIKeyboardAnimationDurationUserInfoKey]).intValue;
        
        [UIView animateWithDuration:animationDuration delay:0.25 options:animationCurve animations:^{
            
            tableView.contentInset=UIEdgeInsetsZero;
            tableView.scrollIndicatorInsets=UIEdgeInsetsZero;
            
        } completion:nil] ;
    }
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}












/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


@implementation UIResponder (BDResponderCategory)

static __weak id currentFirstRes;

+(id)currentTextFieldFirstResponder
{
    currentFirstRes=nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFieldFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstRes;
}

-(void)findFieldFirstResponder:(id)sender
{
    currentFirstRes=self;
}

@end














