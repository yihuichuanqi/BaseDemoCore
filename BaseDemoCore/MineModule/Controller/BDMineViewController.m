//
//  BDMineViewController.m
//  BaseDemoCore
//
//  Created by Admin on 2017/11/7.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "BDMineViewController.h"
#import "BDMineServiceApi.h"
#import "CTMediator+BDOrderModuleActions.h"

@interface BDMineViewController ()

@end

@implementation BDMineViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor redColor];
    
    
    BDMineServiceApi *serviceApi=[[BDMineServiceApi alloc]init];
    [serviceApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"请求成功");
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
       
        NSLog(@"请求失败");
    }];
    
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"点击" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.view).with.offset(100);
        make.centerX.equalTo(self.view);
        
    }];
    
    // Do any additional setup after loading the view.
}
-(void)btnClicked:(UIButton *)button
{
    UIViewController *viewController=[[CTMediator sharedInstance] CTMediator_Order_ViewControllerForOrder];
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
