//
//  BDPublicViewController.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDPublicViewController.h"
#import "CTMediator+BDPublicModuleActions.h"

#define BDScreenW [UIScreen mainScreen].bounds.size.width
#define BDScreenH [UIScreen mainScreen].bounds.size.height

static NSInteger BDSpringFactor =10;
static CGFloat BDSpringDelay =0.1;


@interface BDPublicViewController ()

@end

@implementation BDPublicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor yellowColor];
    
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"下一页" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor=[UIColor redColor];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view).with.offset(74);
        make.centerX.equalTo(self.view);
        
    }];
    
    
    
    NSArray *array=@[@{@"image":@"publish-video",@"name":@"视频"},@{@"image":@"publish-picture",@"name":@"图片"},@{@"image":@"publish-text",@"name":@"段子"},@{@"image":@"publish-audio",@"name":@"声音"},@{@"image":@"publish-review",@"name":@"审帖"},@{@"image":@"publish-offline",@"name":@"离线下载"}];
    
//    [self setupImageViewWithArray:array];

    
    // Do any additional setup after loading the view.
}

-(void)setupImageViewWithArray:(NSArray *)array
{
    NSUInteger cols=3;
    CGFloat btnW=60;
    CGFloat btnH=btnW+30;
    CGFloat beginMagin=20;
    CGFloat middleMagin=(BDScreenW-2*beginMagin-cols*btnW)/(cols-1);
    CGFloat btnStartY=(BDScreenH-2*btnH)*0.5;
    
    for (int i=0; i<array.count; i++)
    {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        NSInteger col=i%cols;
        NSInteger row=i/cols;
        CGFloat btnX=col*(middleMagin+btnW)+beginMagin;
        CGFloat btnY=row*btnH+btnStartY;
        [self.view addSubview:btn];
        
        NSDictionary *dic=array[i];
        [btn setTitle:dic[@"name"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:dic[@"image"]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickBtnDown:) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(clickBtnUpInSide:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag=i;
        
        //添加动画
        CGFloat beginBtnY=btnStartY-BDScreenH;
        POPSpringAnimation *animation=[POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        animation.fromValue=[NSValue valueWithCGRect:CGRectMake(btnX, beginBtnY, btnW, btnH)];
        animation.toValue=[NSValue valueWithCGRect:CGRectMake(btnX, btnY, btnW, btnH)];
        animation.springSpeed=BDSpringFactor;
        animation.springBounciness=BDSpringDelay;
        animation.beginTime=CACurrentMediaTime()+i*BDSpringDelay;
        [btn pop_addAnimation:animation forKey:nil];
        [animation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
            
        }];
        
    }
    
}
-(void)clickBtnDown:(UIButton *)btn
{
    POPBasicAnimation *animation=[POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    animation.toValue=[NSValue valueWithCGSize:CGSizeMake(1.1, 1.1)];
    [btn pop_addAnimation:animation forKey:nil];
}
-(void)clickBtnUpInSide:(UIButton *)btn
{
    POPBasicAnimation *animation=[POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    animation.toValue=[NSValue valueWithCGSize:CGSizeMake(1.3, 1.3)];
    [btn pop_addAnimation:animation forKey:nil];
    [animation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        
        POPBasicAnimation *animation2=[POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        animation2.toValue=@(0);
        [btn pop_addAnimation:animation2 forKey:nil];
        [animation2 setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
            
            
            [self cancelWithCompletionBlock:^{
                
                //切换对应的控制器
            }];
            
        }];
        
    }];
}

-(void)cancelWithCompletionBlock:(void(^)())block
{
    self.view.userInteractionEnabled=NO;
    int index=0;
    for (int i=index; i<self.view.subviews.count; i++)
    {
        UIView *view=self.view.subviews[i];
        POPSpringAnimation *animation=[POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        animation.springBounciness=BDSpringDelay;
        animation.beginTime=CACurrentMediaTime()+(i-index)*BDSpringDelay;
        CGFloat endCenterY=view.frame.origin.y+BDScreenH;
        animation.toValue=[NSValue valueWithCGPoint:CGPointMake(view.frame.origin.x, endCenterY)];
        [view pop_addAnimation:animation forKey:nil];
        if (i==self.view.subviews.count-1)
        {
            //最后一个点动画完成
            [animation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
                
                [self dismissViewControllerAnimated:NO completion:nil];
                block();
            }];
        }
    }
}

-(void)btnClicked:(UIButton *)button
{
    UIViewController *viewController=[[CTMediator sharedInstance] CTMediator_Public_ViewControllerForPublicDetail:nil];
    [self.navigationController pushViewController:viewController animated:YES];
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
