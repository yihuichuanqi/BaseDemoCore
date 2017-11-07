//
//  BDBaseViewController.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/6.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDBaseViewController.h"

@interface BDBaseViewController ()
{
    CGFloat navigationY;
    CGFloat navBarY;
    CGFloat vertialY;
    BOOL _isShowMenu;
}
@property CGFloat original_height;
@end

@implementation BDBaseViewController

-(id)initWithRouterParams:(NSDictionary *)params
{
    self=[super init];
    if(self)
    {
        _parameterDictionary=params;
        NSLog(@"当前参数:%@",params);
    }
    return self;
}
-(id)init
{
    if(self=[super init])
    {
        [self.navigationController.navigationBar setTranslucent:NO];
        [self.navigationController setNavigationBarHidden:YES];
        navBarY=0;
        navigationY=0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.extendedLayoutIncludesOpaqueBars=YES;
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    //导航背景
    if([self respondsToSelector:@selector(backgroundImage)])
    {
        UIImage *bgImage=[self navBackgroundImage];
        [self setNavigationBackground:bgImage];
    }
    //导航标题
    if([self respondsToSelector:@selector(setTitle)])
    {
        NSMutableAttributedString *titleAttribute=[self setTitle];
        [self set_Title:titleAttribute];
    }
    //左侧按钮
    if(![self leftButton])
    {
        [self configLeftBarItemWithImage];
    }
    if (![self rightButton])
    {
        [self configRightBarItemWithImage];
    }
    
    //添加监听通知
    [self addNSNotificationObserver];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self respondsToSelector:@selector(set_ColorBackground)])
    {
        UIColor *backgroundColor=[self set_ColorBackground];
        UIImage *bgImage=[self imageWithColor:backgroundColor];
        [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
        
    }
    UIImageView *blackLineImageView=[self findHairlineImageViewUnder:self.navigationController.navigationBar];
    //默认显示黑线
    blackLineImageView.hidden=NO;
    if ([self respondsToSelector:@selector(hideNavigationBottomLine)])
    {
        if ([self hideNavigationBottomLine])
        {
            blackLineImageView.hidden=YES;
        }
    }
}



#pragma mark-监听通知
-(void)addNSNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkChanged:) name:kRealReachabilityChangedNotification object:nil];
    [GLobalRealReachability startNotifier];
    
    ReachabilityStatus status=[GLobalRealReachability currentReachabilityStatus];
    if (status==RealStatusNotReachable)
    {
        NSLog(@"当前网络连接失败,请查看");
    }
}
-(void)netWorkChanged:(NSNotification *)noti
{
    RealReachability *reachability=(RealReachability *)noti.object;
    ReachabilityStatus status=[reachability currentReachabilityStatus];
    if (status==RealStatusNotReachable)
    {
        NSLog(@"网络《不可用》");
    }
    if (status==RealStatusViaWiFi)
    {
        NSLog(@"网络《WIFI》");
    }
    WWANAccessType accessType=[GLobalRealReachability currentWWANtype];
    if (accessType==RealStatusViaWWAN)
    {
        if (accessType==WWANType2G)
        {
            NSLog(@"当前为2G网络");
        }
        else if (accessType==WWANType3G)
        {
            NSLog(@"当前为3G网络");
        }
        else if (accessType==WWANType4G)
        {
            NSLog(@"当前为4G网络");
        }
    }
}

-(void)setNavigationBackground:(UIImage *)image
{
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor=[UIColor clearColor];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:image];
    [self.navigationController.navigationBar setShadowImage:image];
}

-(void)set_Title:(NSMutableAttributedString *)title
{
    UILabel *navTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
    navTitleLabel.numberOfLines=0;
    [navTitleLabel setAttributedText:title];
    navTitleLabel.textAlignment=NSTextAlignmentCenter;
    navTitleLabel.backgroundColor=[UIColor clearColor];
    navTitleLabel.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleTapClicked:)];
    [navTitleLabel addGestureRecognizer:tap];
    self.navigationItem.titleView=navTitleLabel;
}
-(void)titleTapClicked:(UITapGestureRecognizer *)p
{
    UIView *view=p.view;
    if ([self respondsToSelector:@selector(title_Clicked_Event:)])
    {
        [self title_Clicked_Event:view];
    }
}

#pragma mark-Item
-(void)configLeftBarItemWithImage
{
    if ([self respondsToSelector:@selector(set_LeftBarButtonItemWithImage)])
    {
        UIImage *image=[self set_LeftBarButtonItemWithImage];
        UIBarButtonItem *leftItem=[[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(left_Click:)];
        self.navigationItem.backBarButtonItem=leftItem;
    }
}
-(void)configRightBarItemWithImage
{
    if ([self respondsToSelector:@selector(set_RightBarButtonItemWithImage)])
    {
        UIImage *image=[self set_RightBarButtonItemWithImage];
        UIBarButtonItem *rightItem=[[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(left_Click:)];
        self.navigationItem.rightBarButtonItem=rightItem;
    }
}
-(BOOL)leftButton
{
    BOOL isLeft=[self respondsToSelector:@selector(set_LeftButton)];
    if(isLeft)
    {
        UIButton *leftBtn=[self set_LeftButton];
        [leftBtn addTarget:self action:@selector(left_Click:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem=[[UIBarButtonItem alloc]initWithCustomView:leftBtn];
        self.navigationItem.rightBarButtonItem=leftItem;
    }
    return isLeft;
}
-(BOOL)rightButton
{
    BOOL isRight=[self respondsToSelector:@selector(set_RightButton)];
    if (isRight)
    {
        UIButton *rightBtn=[self set_RightButton];
        [rightBtn addTarget:self action:@selector(right_Click:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem=[[UIBarButtonItem alloc]initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItem=rightItem;
    }
    return isRight;
    
}


#pragma makr-事件
-(void)left_Click:(id)sender
{
    if([self respondsToSelector:@selector(left_Button_Event:)])
    {
        [self left_Button_Event:sender];
    }
}
-(void)right_Click:(id)sender
{
    if([self respondsToSelector:@selector(right_Button_Event:)])
    {
        [self right_Button_Event:sender];
    }
}


-(void)changeNavigationBarHeight:(CGFloat)offSet
{
    [UIView animateWithDuration:0.3f animations:^{
        self.navigationController.navigationBar.frame=CGRectMake(self.navigationController.navigationBar.frame.origin.x, navigationY, self.navigationController.navigationBar.frame.size.width, offSet);
        
    }];
}
-(void)changeNavigationBarTranslationY:(CGFloat)translationY
{
    self.navigationController.navigationBar.transform=CGAffineTransformMakeTranslation(0, translationY);
}

#pragma mark-其他方法
-(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
//查找nav底部黑线
-(UIImageView *)findHairlineImageViewUnder:(UIView *)view
{
    if([view isKindOfClass:UIImageView.class]&&view.bounds.size.height<=1.0)
    {
        return (UIImageView *)view;
    }
    for (UIView *subView in view.subviews)
    {
        UIImageView *imageView=[self findHairlineImageViewUnder:subView];
        if (imageView)
        {
            return imageView;
        }
    }
    return nil;
}

-(void)dealloc
{
    //回收资源
    [GLobalRealReachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
