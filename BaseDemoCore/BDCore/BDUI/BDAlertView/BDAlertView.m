//
//  BDAlertView.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/9.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDAlertView.h"
#import "BDCoreMacros.h"

NSString *const BDAlertViewWillShowNotification=@"BDAlertViewWillShowNotification";
NSString *const BDAlertViewDidShowNotification=@"BDAlertViewDidShowNotification";
NSString *const BDAlertViewWillDismissNotification=@"BDAlertViewWillDismissNotification";
NSString *const BDAlertViewDidDismissNotification=@"BDAlertViewDidDismissNotification";

#define BDAlertViewWidth 280
#define BDAlertViewHeight 150
#define BDAlertViewMaxHeight 440
#define BDMargin 0
#define BDContentMargin 15
#define BDButtonHeight 44
#define BDAlertViewTitleLabelHeight 40
#define BDAlertViewTitleColor RGB(65,65,65)
#define BDAlertViewTitleFont [UIFont boldSystemFontOfSize:20]
#define BDAlertViewContentColor RGB(102,102,102)
#define BDAlertViewContentFont [UIFont boldSystemFontOfSize:14]
#define BDAlertViewContentHeight (BDAlertViewHeight-BDAlertViewTitleLabelHeight-BDButtonHeight-BDMargin*2)

@protocol BDViewControllerDelegare<NSObject>

@optional
-(void)coverViewTouched;

@end

@interface BDAlertController : UIViewController

@property (nonatomic,strong) UIImageView *screenShotView;
@property (nonatomic,strong) UIButton *coverView;
@property (nonatomic,weak) BDAlertView *alertView;
@property (nonatomic,weak) id<BDViewControllerDelegare> delegate;

@end

@implementation BDAlertController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)addScreenShot
{
    
}
@end





@interface BDAlertView ()<BDViewControllerDelegare>

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,strong) NSArray *buttons;
@property (nonatomic,strong) NSArray *clicks;

@property (nonatomic,copy) ClickHandlerWithIndex clickWithIndex;

@end

@implementation BDAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
